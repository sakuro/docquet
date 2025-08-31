# frozen_string_literal: true

RSpec.describe RubocopConfig::PluginDetector do
  let(:mock_performance_spec) do
    instance_double(Gem::Specification,
                    name: "rubocop-performance",
                    metadata: {"default_lint_roller_plugin" => "RuboCop::Performance::Plugin"})
  end

  let(:mock_rspec_spec) do
    instance_double(Gem::Specification,
                    name: "rubocop-rspec", 
                    metadata: {"default_lint_roller_plugin" => "RuboCop::RSpec::Plugin"})
  end

  let(:mock_thread_safety_spec) do
    instance_double(Gem::Specification,
                    name: "rubocop-thread_safety",
                    metadata: {"default_lint_roller_plugin" => "RuboCop::ThreadSafety::Plugin"})
  end

  let(:mock_ast_spec) do
    instance_double(Gem::Specification,
                    name: "rubocop-ast",
                    metadata: {})  # No plugin metadata
  end

  let(:mock_non_plugin_spec) do
    instance_double(Gem::Specification,
                    name: "rubocop-custom",
                    metadata: {})
  end

  let(:mock_unrelated_spec) do
    instance_double(Gem::Specification,
                    name: "rails",
                    metadata: {"default_lint_roller_plugin" => "Rails::SomeOtherPlugin"})
  end

  let(:mock_another_unrelated_spec) do
    instance_double(Gem::Specification,
                    name: "rspec-core", 
                    metadata: {})
  end

  let(:all_rubocop_specs) do
    [
      mock_performance_spec,
      mock_rspec_spec,
      mock_thread_safety_spec,
      mock_ast_spec,
      mock_non_plugin_spec
    ]
  end

  before do
    allow(Gem::Specification).to receive(:select) do |&block|
      all_rubocop_specs.select(&block)
    end
  end

  describe ".detect_plugin_gem_names" do
    it "returns an array of plugin gem names" do
      result = described_class.detect_plugin_gem_names
      
      expect(result).to be_an(Array)
      expect(result).to all(be_a(String))
      expect(result).to all(start_with("rubocop-"))
    end

    it "includes gems with default_lint_roller_plugin metadata" do
      result = described_class.detect_plugin_gem_names
      
      expect(result).to include("rubocop-performance")
      expect(result).to include("rubocop-rspec")
      expect(result).to include("rubocop-thread_safety")
    end

    it "excludes gems without RuboCop plugin metadata pattern" do
      result = described_class.detect_plugin_gem_names
      
      # These don't match RuboCop::.*::Plugin pattern
      expect(result).not_to include("rubocop-ast")      # No metadata
      expect(result).not_to include("rubocop-custom")   # No metadata
      expect(result).not_to include("rails")            # Wrong metadata pattern
      expect(result).not_to include("rspec-core")       # No metadata
    end

    it "filters gems using RuboCop plugin metadata pattern" do
      allow(Gem::Specification).to receive(:select) do |&block|
        # Test that the block correctly identifies RuboCop plugins by metadata
        expect(block.call(mock_performance_spec)).to be_truthy  # Has RuboCop::Performance::Plugin
        expect(block.call(mock_rspec_spec)).to be_truthy        # Has RuboCop::RSpec::Plugin
        expect(block.call(mock_ast_spec)).to be_falsy           # No plugin metadata
        expect(block.call(mock_non_plugin_spec)).to be_falsy    # No plugin metadata
        expect(block.call(mock_unrelated_spec)).to be_falsy     # Not a RuboCop plugin
        all_rubocop_specs.select(&block)
      end

      described_class.detect_plugin_gem_names

      expect(Gem::Specification).to have_received(:select)
    end
  end

  describe ".detect_plugin_names" do
    it "returns plugin names without rubocop- prefix" do
      result = described_class.detect_plugin_names
      
      expect(result).to be_an(Array)
      expect(result).to all(be_a(String))
      expect(result).to all(satisfy { |name| !name.start_with?("rubocop-") })
    end

    it "strips rubocop- prefix from gem names" do
      result = described_class.detect_plugin_names
      
      expect(result).to include("performance")
      expect(result).to include("rspec")  
      expect(result).to include("thread_safety")
    end

    it "corresponds to detect_plugin_gem_names without prefix" do
      gem_names = described_class.detect_plugin_gem_names
      plugin_names = described_class.detect_plugin_names
      
      expected_names = gem_names.map { |name| name.delete_prefix("rubocop-") }
      expect(plugin_names).to eq(expected_names)
    end
  end
end