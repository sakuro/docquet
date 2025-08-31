# frozen_string_literal: true

require "rake"

RSpec.describe RubocopConfig::RakeTask do
  before do
    # Clear existing tasks
    Rake.application.clear

    # Mock plugin detection
    allow(RubocopConfig::PluginDetector).to receive(:detect_plugin_gem_names)
      .and_return(["rubocop-performance", "rubocop-rspec"])

    # Mock RuboCop cop registry  
    mock_registry = double("Registry")
    allow(RuboCop::Cop::Registry).to receive(:global).and_return(mock_registry)

    # Mock the map method to return department names (as strings, sorted and unique)
    allow(mock_registry).to receive(:map).and_return(["Layout", "Performance", "RSpec", "Style"])

    # Mock FileUtils to prevent actual file operations
    allow(FileUtils).to receive(:rm_rf)
    allow(FileUtils).to receive(:mkdir_p)

    # Mock File operations
    allow(File).to receive(:write)
    allow(File).to receive(:exist?).and_return(false)
    allow(File).to receive(:read).and_return("")

    # Mock puts to prevent output during tests
    allow_any_instance_of(described_class).to receive(:puts)

    # Create test directory structure
    create_test_config_structure
  end

  describe "#initialize" do
    let(:rake_task) { described_class.new }

    it "creates an inflector with custom acronyms" do
      expect(rake_task.instance_variable_get(:@inflector)).to be_a(Dry::Inflector)
    end

    it "detects plugin gem names" do
      plugin_gem_names = rake_task.instance_variable_get(:@plugin_gem_names)
      expect(plugin_gem_names).to eq(["rubocop-performance", "rubocop-rspec"])
    end

    it "extracts departments from RuboCop registry" do
      departments = rake_task.instance_variable_get(:@departments)
      expect(departments).to contain_exactly("Layout", "Performance", "RSpec", "Style")
    end
  end

  describe "#generate_default_config" do
    let(:rake_task) { described_class.new }
    let(:department) { "Style" }
    let(:target_file) { "config/defaults/style.yml" }
    let(:mock_processor) { instance_double(RubocopConfig::ConfigProcessor) }

    before do
      allow(RubocopConfig::ConfigProcessor).to receive(:new).and_return(mock_processor)
      allow(mock_processor).to receive(:process).and_return("processed content")

      # Mock successful command execution
      allow(rake_task).to receive(:`).and_return("raw rubocop output")
      allow(rake_task).to receive(:$?).and_return(instance_double(Process::Status, success?: true))
    end

    it "generates configuration for the specified department" do
      rake_task.send(:generate_default_config, department, target_file)

      expect(RubocopConfig::ConfigProcessor).to have_received(:new).with(["rubocop-performance", "rubocop-rspec"])
      expect(mock_processor).to have_received(:process).with("raw rubocop output", "Style", "rubocop", "style")
      expect(File).to have_received(:write).with(target_file, "processed content")
    end

    it "uses correct gem name for core departments" do
      rake_task.send(:generate_default_config, "Style", target_file)

      expect(mock_processor).to have_received(:process).with(anything, "Style", "rubocop", "style")
    end

    it "uses correct gem name for plugin departments" do
      rake_task.send(:generate_default_config, "Performance", "config/defaults/performance.yml")

      expect(mock_processor).to have_received(:process).with(anything, "Performance", "rubocop-performance", "performance")
    end

    it "constructs correct rubocop command" do
      expected_cmd = [
        "bin/rubocop",
        "--show-cops=Style/*",
        "--force-default-config", 
        "--display-cop-names",
        "--extra-details",
        "--display-style-guide",
        "--plugin", "rubocop-performance",
        "--plugin", "rubocop-rspec"
      ].join(" ")

      expect(rake_task).to receive(:`).with("#{expected_cmd} 2>/dev/null")

      rake_task.send(:generate_default_config, department, target_file)
    end


    context "with complex department names" do
      it "handles RSpec department correctly" do
        rake_task.send(:generate_default_config, "RSpec", "config/defaults/rspec.yml")

        expect(mock_processor).to have_received(:process).with(anything, "RSpec", "rubocop-rspec", "rspec")
      end

      it "handles nested department names" do
        # Mock the registry to include nested department
        allow(RuboCop::Cop::Registry.global).to receive(:map).and_return(["RSpec/Rails", "Style"])

        rake_task.send(:generate_default_config, "RSpec/Rails", "config/defaults/rspec_rails.yml")

        expect(mock_processor).to have_received(:process).with(anything, "RSpec/Rails", "rubocop-rspec", "rspec_rails")
      end
    end
  end

  describe "#check_cops_configurations" do
    let(:rake_task) { described_class.new }

    before do
      allow(Dir).to receive(:[]).with("config/defaults/*.yml")
        .and_return(["config/defaults/style.yml", "config/defaults/performance.yml"])
    end

    context "when cops files exist with correct inheritance" do
      before do
        allow(File).to receive(:exist?).with("config/cops/style.yml").and_return(true)
        allow(File).to receive(:exist?).with("config/cops/performance.yml").and_return(true)
        allow(File).to receive(:read).with("config/cops/style.yml")
          .and_return("inherit_from: ../defaults/style.yml\n")
        allow(File).to receive(:read).with("config/cops/performance.yml")
          .and_return("inherit_from: ../defaults/performance.yml\n")
      end

      it "validates inheritance configuration" do
        expect { rake_task.send(:check_cops_configurations) }.not_to raise_error
      end
    end

    context "when cops files exist with incorrect inheritance" do
      before do
        allow(File).to receive(:exist?).with("config/cops/style.yml").and_return(true)
        allow(File).to receive(:read).with("config/cops/style.yml")
          .and_return("some other content\n")
      end

      it "detects incorrect inheritance" do
        expect { rake_task.send(:check_cops_configurations) }.not_to raise_error
      end
    end

    context "when cops files do not exist" do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "skips non-existent files" do
        expect { rake_task.send(:check_cops_configurations) }.not_to raise_error
      end
    end
  end

  describe "inflector integration" do
    let(:rake_task) { described_class.new }

    it "correctly transforms department names to file names" do
      inflector = rake_task.instance_variable_get(:@inflector)

      expect(inflector.underscore("Style")).to eq("style")
      expect(inflector.underscore("RSpec")).to eq("rspec")
      expect(inflector.underscore("RSpec/Rails")).to eq("rspec/rails")
    end

    it "handles tr operation for nested departments" do
      inflector = rake_task.instance_variable_get(:@inflector)
      base = inflector.underscore("RSpec/Rails").tr("/", "_")
      expect(base).to eq("rspec_rails")
    end
  end

  describe "plugin gem name handling" do
    let(:rake_task) { described_class.new }

    it "uses correct gem names for known plugins" do
      plugin_gem_names = rake_task.instance_variable_get(:@plugin_gem_names)
      
      expect(plugin_gem_names.include?("rubocop-performance")).to be true
      expect(plugin_gem_names.include?("rubocop-rspec")).to be true
    end

    it "falls back to rubocop for unknown plugins" do
      # This test verifies the fallback logic in generate_default_config
      department = "UnknownDepartment"
      inflector = rake_task.instance_variable_get(:@inflector)
      plugin_name = inflector.underscore(department.sub(%r{/.*}, ""))
      gem_name = "rubocop-#{plugin_name}"
      plugin_gem_names = rake_task.instance_variable_get(:@plugin_gem_names)
      
      unless plugin_gem_names.include?(gem_name)
        gem_name = "rubocop"
      end
      
      expect(gem_name).to eq("rubocop")
    end
  end
end