# frozen_string_literal: true

RSpec.describe Docquet::Generators::RuboCopYMLGenerator do
  let(:generator) { Docquet::Generators::RuboCopYMLGenerator.new }
  let(:config_dir) { File.join(File.dirname(__dir__, 4), "config", "cops") }
  let(:defaults_dir) { File.join(File.dirname(__dir__, 4), "config", "defaults") }
  let(:template_dir) { File.join(File.dirname(__dir__, 4), "templates") }

  before do
    # Create test directory structure
    create_test_config_structure

    # Create mock config files
    create_test_file("config/cops/style.yml", "inherit_from: ../defaults/style.yml\n")
    create_test_file("config/cops/layout.yml", "inherit_from: ../defaults/layout.yml\n")
    create_test_file("config/cops/performance.yml", "inherit_from: ../defaults/performance.yml\n")
    create_test_file("config/cops/rspec.yml", "inherit_from: ../defaults/rspec.yml\n")

    # Create mock defaults files with department headers
    create_test_file("config/defaults/style.yml", "# Department 'Style' (20):\n")
    create_test_file("config/defaults/layout.yml", "# Department 'Layout' (15):\n")
    create_test_file("config/defaults/performance.yml", "# Department 'Performance' (10):\n")
    create_test_file("config/defaults/rspec.yml", "# Department 'RSpec' (8):\n")

    # Create template file
    create_test_file("templates/rubocop.yml.erb", <<~ERB)
      TargetRubyVersion: <%= detected_ruby_version %>

      inherit_from:
      <% @filtered_configs.each do |config| -%>
        - config/cops/<%= config %>.yml
      <% end -%>
    ERB

    # Mock plugin detector
    allow(Docquet::PluginDetector).to receive(:detect_plugin_names)
      .and_return(%w[performance rspec])

    # Mock file paths to use local test structure
    allow_any_instance_of(Docquet::Generators::RuboCopYMLGenerator).to receive(:template_path) do |_, filename|
      File.join("templates", filename)
    end
  end

  describe "#initialize" do
    it "creates an inflector with custom acronyms" do
      expect(generator.instance_variable_get(:@inflector)).to be_a(Dry::Inflector)
    end

    it "detects plugin names" do
      detected_plugins = generator.instance_variable_get(:@detected_plugin_names)
      expect(detected_plugins).to eq(%w[performance rspec])
    end

    it "filters config files based on available plugins" do
      filtered_configs = generator.instance_variable_get(:@filtered_configs)
      expect(filtered_configs).to include("style")
      expect(filtered_configs).to include("layout")
      expect(filtered_configs).to include("performance")
      expect(filtered_configs).to include("rspec")
    end
  end

  describe "#generate" do
    before do
      create_test_file(".ruby-version", "3.1.0")
    end

    it "generates .rubocop.yml file with correct content" do
      generator.generate

      expect(File.exist?(".rubocop.yml")).to be true
      content = File.read(".rubocop.yml")

      expect(content).to include("TargetRubyVersion: 3.1.0")
      expect(content).to include("inherit_from:")
      expect(content).to include("- config/cops/style.yml")
      expect(content).to include("- config/cops/layout.yml")
      expect(content).to include("- config/cops/performance.yml")
      expect(content).to include("- config/cops/rspec.yml")
    end

    it "overwrites existing .rubocop.yml file" do
      File.write(".rubocop.yml", "old content")
      generator.generate

      content = File.read(".rubocop.yml")
      expect(content).not_to include("old content")
      expect(content).to include("TargetRubyVersion:")
    end
  end

  describe "#detected_ruby_version" do
    context "when .ruby-version exists" do
      before do
        create_test_file(".ruby-version", "3.2.1\n")
      end

      it "returns version from .ruby-version file" do
        version = generator.send(:detected_ruby_version)
        expect(version).to eq("3.2.1")
      end

      it "strips whitespace from version" do
        create_test_file(".ruby-version", "  3.1.0  \n")
        version = generator.send(:detected_ruby_version)
        expect(version).to eq("3.1.0")
      end
    end

    context "when .ruby-version does not exist" do
      it "returns major.minor version from RUBY_VERSION" do
        version = generator.send(:detected_ruby_version)
        expect(version).to match(/\A\d+\.\d+\z/)
        expect(version).to eq(RUBY_VERSION[/\A\d+\.\d+/])
      end
    end
  end

  describe "#detect_available_config_files" do
    it "returns list of yml files from config/cops directory" do
      config_files = generator.send(:detect_available_config_files)

      expect(config_files).to be_an(Array)
      expect(config_files).to include("style")
      expect(config_files).to include("layout")
      expect(config_files).to include("performance")
      expect(config_files).to include("rspec")
    end

    it "returns basenames without extension" do
      config_files = generator.send(:detect_available_config_files)

      config_files.each do |config|
        expect(config).not_to end_with(".yml")
      end
    end
  end

  describe "#filtered_config_files" do
    context "with detected plugins" do
      before do
        allow(Docquet::PluginDetector).to receive(:detect_plugin_names)
          .and_return(%w[performance rspec])
      end

      it "includes core departments" do
        filtered_configs = generator.send(:filtered_config_files)

        expect(filtered_configs).to include("style")
        expect(filtered_configs).to include("layout")
      end

      it "includes detected plugin departments" do
        filtered_configs = generator.send(:filtered_config_files)

        expect(filtered_configs).to include("performance")
        expect(filtered_configs).to include("rspec")
      end
    end

    context "without detected plugins" do
      before do
        allow(Docquet::PluginDetector).to receive(:detect_plugin_names)
          .and_return([])
      end

      it "includes only core departments" do
        new_generator = Docquet::Generators::RuboCopYMLGenerator.new
        filtered_configs = new_generator.send(:filtered_config_files)

        expect(filtered_configs).to include("style")
        expect(filtered_configs).to include("layout")
        expect(filtered_configs).not_to include("performance")
        expect(filtered_configs).not_to include("rspec")
      end
    end

    context "with mixed available configs" do
      before do
        create_test_file("config/cops/unknown_plugin.yml", "inherit_from: ../defaults/unknown_plugin.yml\n")
        create_test_file("config/defaults/unknown_plugin.yml", "# Department 'UnknownPlugin' (5):\n")

        allow(Docquet::PluginDetector).to receive(:detect_plugin_names)
          .and_return(["performance"])
      end

      it "filters correctly based on detection" do
        new_generator = Docquet::Generators::RuboCopYMLGenerator.new
        filtered_configs = new_generator.send(:filtered_config_files)

        expect(filtered_configs).to include("style")
        expect(filtered_configs).to include("performance")
        expect(filtered_configs).not_to include("rspec")
        expect(filtered_configs).not_to include("unknown_plugin")
      end
    end
  end

  describe "#extract_department_from_config" do
    it "extracts department from defaults file header" do
      department = generator.send(:extract_department_from_config, "style")
      expect(department).to eq("Style")
    end

    it "handles different department names correctly" do
      department = generator.send(:extract_department_from_config, "performance")
      expect(department).to eq("Performance")
    end

    it "handles RSpec acronym correctly" do
      department = generator.send(:extract_department_from_config, "rspec")
      expect(department).to eq("RSpec")
    end

    context "when defaults file doesn't exist" do
      before do
        create_test_file("config/cops/missing_defaults.yml", "inherit_from: ../defaults/nonexistent.yml\n")
      end

      it "falls back to simple split method" do
        department = generator.send(:extract_department_from_config, "missing_defaults")
        expect(department).to eq("missing")
      end
    end

    context "when cops file doesn't exist" do
      it "falls back to simple split method" do
        department = generator.send(:extract_department_from_config, "nonexistent_config")
        expect(department).to eq("nonexistent")
      end
    end

    context "when defaults file has no department header" do
      before do
        create_test_file("config/cops/no_header.yml", "inherit_from: ../defaults/no_header.yml\n")
        create_test_file("config/defaults/no_header.yml", "# Some other content\n")
      end

      it "falls back to simple split method" do
        department = generator.send(:extract_department_from_config, "no_header")
        expect(department).to eq("no")
      end
    end

    context "with complex config file names" do
      it "handles underscored names correctly" do
        create_test_file("config/cops/thread_safety.yml", "inherit_from: ../defaults/thread_safety.yml\n")
        create_test_file("config/defaults/thread_safety.yml", "# Department 'ThreadSafety' (3):\n")

        department = generator.send(:extract_department_from_config, "thread_safety")
        expect(department).to eq("ThreadSafety")
      end
    end
  end

  describe "integration with inflector" do
    it "properly handles acronym inflection" do
      inflector = generator.instance_variable_get(:@inflector)

      expect(inflector.underscore("RSpec")).to eq("rspec")
      expect(inflector.underscore("GetText")).to eq("gettext")
      expect(inflector.underscore("RailsI18n")).to eq("railsi18n")
    end

    it "filters configs using inflector for department matching" do
      # Since the test environment doesn't have actual config files,
      # we just verify the core departments are included
      filtered_configs = generator.send(:filtered_config_files)

      expect(filtered_configs).to include("style")
      expect(filtered_configs).to include("layout")
    end
  end
end
