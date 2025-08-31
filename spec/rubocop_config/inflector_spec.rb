# frozen_string_literal: true

RSpec.describe RubocopConfig::Inflector do
  describe ".instance" do
    it "returns a Dry::Inflector instance" do
      expect(described_class.instance).to be_a(Dry::Inflector)
    end

    it "returns the same instance on multiple calls (memoized)" do
      first_call = described_class.instance
      second_call = described_class.instance
      expect(first_call).to be(second_call)
    end
  end

  describe "acronym handling" do
    let(:inflector) { described_class.instance }

    it "correctly handles RSpec acronym" do
      expect(inflector.underscore("RSpec")).to eq("rspec")
      expect(inflector.underscore("RSpecCapybara")).to eq("rspec_capybara")
      expect(inflector.underscore("RSpec/Rails")).to eq("rspec/rails")
    end

    it "correctly handles GetText acronym" do
      expect(inflector.underscore("GetText")).to eq("gettext")
      expect(inflector.underscore("GetTextHelper")).to eq("gettext_helper")
    end

    it "correctly handles RailsI18n acronym" do
      expect(inflector.underscore("RailsI18n")).to eq("railsi18n")
      expect(inflector.underscore("RailsI18nHelper")).to eq("railsi18n_helper")
    end

    it "handles standard transformations without acronyms" do
      expect(inflector.underscore("Style")).to eq("style")
      expect(inflector.underscore("Layout")).to eq("layout")
      expect(inflector.underscore("Performance")).to eq("performance")
    end

    it "handles nested department names" do
      expect(inflector.underscore("RSpec/Capybara")).to eq("rspec/capybara")
      expect(inflector.underscore("RSpec/FactoryBot")).to eq("rspec/factory_bot")
    end
  end

  describe "consistency with existing usage" do
    let(:inflector) { described_class.instance }

    it "transforms department names consistently for file naming" do
      department = "RSpec/Rails"
      base = inflector.underscore(department).tr("/", "_")
      expect(base).to eq("rspec_rails")
    end

    it "transforms plugin names consistently" do
      plugin_name = inflector.underscore("RSpec")
      expect(plugin_name).to eq("rspec")
    end
  end
end
