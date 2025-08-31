# frozen_string_literal: true

RSpec.describe Docquet::ConfigProcessor do
  let(:plugin_names) { %w[performance rspec thread_safety] }
  let(:processor) { Docquet::ConfigProcessor.new(plugin_names) }

  describe "#initialize" do
    it "stores plugin names" do
      processor = Docquet::ConfigProcessor.new(plugin_names)
      expect(processor.instance_variable_get(:@plugin_names)).to eq(plugin_names)
    end
  end

  describe "#process" do
    let(:department) { "Style" }
    let(:gem_name) { "rubocop" }
    let(:base) { "style" }

    it "applies all processing steps in correct order" do
      content = <<~YAML
        Style/AccessorGrouping:
          Enabled: false
        Style/Alias:
          Enabled: pending
      YAML

      result = processor.process(content, department, gem_name, base)

      # Should have department header
      expect(result).to start_with("# Department 'Style' (2):")

      # Should have enabled all cops
      expect(result).to include("Enabled: true # was false")
      expect(result).to include("Enabled: true # was pending")

      # Should have documentation links
      expect(result).to include("https://docs.rubocop.org/rubocop/cops_style.html#styleaccessorgrouping")
      expect(result).to include("https://docs.rubocop.org/rubocop/cops_style.html#stylealias")
    end

    it "handles empty content" do
      result = processor.process("", department, gem_name, base)
      expect(result).to eq("# Department 'Style' (0):\n")
    end

    it "processes complex content correctly" do
      content = <<~YAML
        Style/AccessorGrouping:
          Description: 'Group accessor methods.'
          Enabled: false
          AllowOnlyRestArgument: true

        Style/Alias:
          Description: 'Use alias_method instead of alias.'
          Enabled: pending
          AllowOnlyRestArgument: false#{"  "}
      YAML

      result = processor.process(content, department, gem_name, base)

      # Check department header
      expect(result).to start_with("# Department 'Style' (2):")

      # Check documentation links added
      expect(result).to include("# https://docs.rubocop.org/rubocop/cops_style.html#styleaccessorgrouping\n")
      expect(result).to include("# https://docs.rubocop.org/rubocop/cops_style.html#stylealias\n")

      # Check enabled cops
      expect(result).to include("Enabled: true # was false")
      expect(result).to include("Enabled: true # was pending")

      # Check deprecated config removed
      expect(result).not_to include("AllowOnlyRestArgument")
    end
  end

  describe "#add_department_header" do
    it "adds header with correct cop count" do
      content = <<~YAML
        Style/AccessorGrouping:
          Enabled: false
        Style/Alias:
          Enabled: true
        Layout/ArrayAlignment:
          Enabled: false
      YAML

      result = processor.send(:add_department_header, content, "Style")
      expect(result).to start_with("# Department 'Style' (2):\n")
      expect(result).to include(content)
    end

    it "handles zero cops" do
      content = "# Some comment\n"
      result = processor.send(:add_department_header, content, "Style")
      expect(result).to start_with("# Department 'Style' (0):\n")
    end

    it "handles department with special characters" do
      content = "Lint/AmbiguousAssignment:\n  Enabled: false\n"
      result = processor.send(:add_department_header, content, "Lint")
      expect(result).to start_with("# Department 'Lint' (1):\n")
    end
  end

  describe "#enable_all_cops" do
    it "converts Enabled: false to true with comment" do
      content = <<~YAML
        SomeCop:
          Enabled: false
      YAML

      result = processor.send(:enable_all_cops, content)
      expect(result).to include("Enabled: true # was false")
    end

    it "converts Enabled: pending to true with comment" do
      content = <<~YAML
        SomeCop:
          Enabled: pending
      YAML

      result = processor.send(:enable_all_cops, content)
      expect(result).to include("Enabled: true # was pending")
    end

    it "leaves Enabled: true unchanged" do
      content = <<~YAML
        SomeCop:
          Enabled: true
      YAML

      result = processor.send(:enable_all_cops, content)
      expect(result).to include("Enabled: true")
      expect(result).not_to include("# was")
    end

    it "handles multiple cops with different states" do
      content = <<~YAML
        Cop1:
          Enabled: false
        Cop2:
          Enabled: pending
        Cop3:
          Enabled: true
      YAML

      result = processor.send(:enable_all_cops, content)
      expect(result).to include("Enabled: true # was false")
      expect(result).to include("Enabled: true # was pending")
      expect(result).to match(/Cop3:\s+Enabled: true(?!\s+# was)/)
    end

    it "only matches exact indentation" do
      content = <<~YAML
        SomeCop:
          Enabled: false
            Enabled: false
      YAML

      result = processor.send(:enable_all_cops, content)
      lines = result.lines
      expect(lines[1]).to include("Enabled: true # was false")
      expect(lines[2]).to include("    Enabled: false")
    end
  end

  describe "#remove_deprecated_config" do
    it "removes AllowOnlyRestArgument lines" do
      content = <<~YAML
        SomeCop:
          Enabled: true
          AllowOnlyRestArgument: true
          Description: 'Some description'
      YAML

      result = processor.send(:remove_deprecated_config, content)
      expect(result).not_to include("AllowOnlyRestArgument")
      expect(result).to include("Enabled: true")
      expect(result).to include("Description: 'Some description'")
    end

    it "handles multiple AllowOnlyRestArgument occurrences" do
      content = <<~YAML
        Cop1:
          AllowOnlyRestArgument: true
        Cop2:
          Enabled: false
          AllowOnlyRestArgument: false
        Cop3:
          Description: 'No deprecated config'
      YAML

      result = processor.send(:remove_deprecated_config, content)
      expect(result).not_to include("AllowOnlyRestArgument")
      expect(result).to include("Cop1:")
      expect(result).to include("Enabled: false")
      expect(result).to include("Description: 'No deprecated config'")
    end

    it "handles content without deprecated config" do
      content = <<~YAML
        SomeCop:
          Enabled: true
          Description: 'Clean config'
      YAML

      result = processor.send(:remove_deprecated_config, content)
      expect(result).to eq(content)
    end
  end

  describe "#add_documentation_links" do
    it "adds documentation links for each cop" do
      content = <<~YAML
        Style/AccessorGrouping:
          Enabled: false
        Style/Alias:
          Enabled: true
      YAML

      result = processor.send(:add_documentation_links, content, "Style", "rubocop", "style")

      expect(result).to include("# https://docs.rubocop.org/rubocop/cops_style.html#styleaccessorgrouping")
      expect(result).to include("# https://docs.rubocop.org/rubocop/cops_style.html#stylealias")
    end

    it "handles different departments and gem names" do
      content = <<~YAML
        Performance/ArraySemiInfiniteRangeSlice:
          Enabled: false
      YAML

      result = processor.send(:add_documentation_links, content, "Performance", "rubocop-performance", "performance")

      expected_url = "# https://docs.rubocop.org/rubocop-performance/cops_performance.html#performancearraysemiinfiniterangeslice"
      expect(result).to include(expected_url)
    end

    it "handles empty content" do
      result = processor.send(:add_documentation_links, "", "Style", "rubocop", "style")
      expect(result).to eq("")
    end

    it "preserves original content structure" do
      content = <<~YAML
        Style/AccessorGrouping:
          Description: 'Group accessor methods.'
          Enabled: false
          AllowedMethods: ['attr_reader', 'attr_writer']
      YAML

      result = processor.send(:add_documentation_links, content, "Style", "rubocop", "style")

      # Should have the link before the cop definition
      lines = result.lines
      expect(lines[0]).to include("# https://docs.rubocop.org")
      expect(lines[1]).to include("Style/AccessorGrouping:")
      expect(lines[2]).to include("Description:")
      expect(lines[3]).to include("Enabled:")
      expect(lines[4]).to include("AllowedMethods:")
    end
  end

  describe "#normalize_paths" do
    before do
      allow(Dir).to receive(:pwd).and_return("/home/user/project")
    end

    it "removes current directory path prefix" do
      content = <<~YAML
        SomeCop:
          Include:
            - /home/user/project/app/**/*.rb
            - /home/user/project/lib/**/*.rb
          Exclude:
            - /home/user/project/spec/**/*
      YAML

      result = processor.send(:normalize_paths, content)

      expect(result).to include("- app/**/*.rb")
      expect(result).to include("- lib/**/*.rb")
      expect(result).to include("- spec/**/*")
      expect(result).not_to include("/home/user/project/")
    end

    it "leaves other paths unchanged" do
      content = <<~YAML
        SomeCop:
          Include:
            - /other/path/file.rb
            - relative/path.rb
      YAML

      result = processor.send(:normalize_paths, content)

      expect(result).to include("- /other/path/file.rb")
      expect(result).to include("- relative/path.rb")
    end

    it "handles content without paths" do
      content = <<~YAML
        SomeCop:
          Enabled: true
          Description: 'No paths here'
      YAML

      result = processor.send(:normalize_paths, content)
      expect(result).to eq(content)
    end
  end

  describe "#remove_trailing_whitespace" do
    it "removes trailing spaces from lines" do
      content = <<~CONTENT
        Line with trailing spaces#{"   "}
        Another line with spaces#{"     "}
        Clean line
        Line with tabs\t\t
      CONTENT

      result = processor.send(:remove_trailing_whitespace, content)

      lines = result.lines
      expect(lines[0]).to end_with("spaces\n")
      expect(lines[1]).to end_with("spaces\n")
      expect(lines[2]).to end_with("line\n")
      expect(lines[3]).to end_with("tabs\t\t\n") # Tabs are preserved, only spaces removed
    end

    it "handles empty lines and lines with only whitespace" do
      content = "Line 1\n   \n\nLine 4   \n"
      result = processor.send(:remove_trailing_whitespace, content)

      expect(result).to eq("Line 1\n\n\nLine 4\n")
    end

    it "handles content without trailing whitespace" do
      content = "Clean line 1\nClean line 2\n"
      result = processor.send(:remove_trailing_whitespace, content)
      expect(result).to eq(content)
    end
  end
end
