# frozen_string_literal: true

require "erb"
require "rbconfig"
require "stringio"
require "yaml"

gems_departments = {
  "rubocop" => %w[Bundler Gemspec Layout Lint Metrics Migration Naming Security Style],
  "rubocop-capybara" => %w[Capybara Capybara/Rspec],
  "rubocop-i18n" => %w[I18n/GetText I18n/RailsI18n],
  "rubocop-rake" => %w[Rake],
  "rubocop-rspec" => %w[RSpec],
  "rubocop-sequel" => %w[Sequel],
  "rubocop-thread_safety" => %w[ThreadSafety],
  "rubocop-performance" => %w[Performance]
}.freeze

dot_rubocop_yml_template = <<~YAML
  AllCops:
    DisplayCopNames: true
    DisplayStyleGuide: true
    EnabledByDefault: true
    Exclude:
    - bin/**/*
    - vendor/**/*
    ExtraDetails: true
    TargetRubyVersion: 0.0
    UseCache: true
  inherit_mode:
    merge:
    - Exclude
  plugins: []
  require: []
  inherit_from: []
YAML

rubocop_gems = Gem::Specification.select { /\Arubocop-(?!ast$)/ =~ it.name }
plugins, extensions = rubocop_gems.partition { it.metadata["default_lint_roller_plugin"] }
plugin_names = plugins.map(&:name)
extension_names = extensions.map(&:name)
departments = gems_departments.slice("rubocop", *plugin_names, *extension_names).values.flatten
departments.sort!

desc "Generate RuboCop configuration"
file ".rubocop.yml" do |t|
  config = YAML.safe_load(dot_rubocop_yml_template)
  config["AllCops"]["TargetRubyVersion"] = Float(RbConfig::CONFIG["RUBY_API_VERSION"])
  config["plugins"] = plugin_names.sort
  config["require"] = extension_names.sort
  config["inherit_from"] = departments.map {|name|
    (Pathname(__dir__) / ".." / "#{name.downcase.tr("/", "_")}.yml")
  }.filter_map {|path| path.exist? && path.relative_path_from(Dir.pwd).to_s }

  out = StringIO.new
  YAML.dump(config, out)
  File.write(t.name, out.string)
end
