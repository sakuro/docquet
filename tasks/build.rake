# frozen_string_literal: true

require "dry-inflector"
require "rubocop"
require "rubocop-capybara"
require "rubocop-i18n"
require "rubocop-performance"
require "rubocop-rake"
require "rubocop-rspec"
require "rubocop-sequel"
require "rubocop-thread_safety"
require "uri"
require "yaml"

namespace :build do
  inflector = Dry::Inflector.new do |inflections|
    inflections.acronym("RSpec")
    inflections.acronym("GetText")
    inflections.acronym("RailsI18n")
    inflections.acronym("ThreadSafety")
  end

  rubocop_gems = Gem::Specification.select { /\Arubocop-(?!ast$)/ =~ it.name }
  plugins, extensions = rubocop_gems.partition { it.metadata["default_lint_roller_plugin"] }
  plugin_names = plugins.map(&:name)
  extension_names = extensions.map(&:name)
  departments = RuboCop::Cop::Registry.global.map {|c| c.department.to_s }
  departments.sort!
  departments.uniq!

  desc "Generate default configuration"
  task all: "build/all.yml"

  departments.each do |department|
    base = department.downcase.tr("/", "_")
    gem_name = "rubocop-#{department.downcase.sub(%r{/.*}, "")}"
    gem_name = "rubocop" unless plugin_names.include?(gem_name) || extension_names.include?(gem_name)

    desc "Generate configuration for #{department}"
    file "default/#{base}.yml" => %W[build/#{base}.yml default] do |t|
      content = File.read(t.source)

      # Enable all cops
      content.gsub!(/(?<=^  )Enabled: (false|pending)$/) { "Enabled: true # was #{$1}" }

      # Remove deprecated configuration
      content.gsub!(/^\s+AllowOnlyRestArgument:.*\n/, "")

      # Insert link to RuboCop documentation
      content.gsub!(%r{(?=^#{department}/(.+):$)}) do
        cop_name = $1
        path = "/#{gem_name}/cops_#{base}.html"
        fragment = "#{department}#{cop_name}".downcase.delete("/_")

        "# #{URI::HTTPS.build(scheme: "https", host: "docs.rubocop.org", path:, fragment:)}\n"
      end

      # Replace absolute path with relative path
      content.gsub!("#{Dir.pwd}/", "")

      File.write(t.name, content)
    end

    Rake::Task["build:all"].enhance ["default/#{base}.yml"]
  end

  desc "Generate build directory"
  directory "build"

  desc "Generate destination directory"
  directory "default"

  rule %r{\Abuild/(.+).yml\z} => "build/all.yml" do |t|
    department = t.name[%r{\Abuild/(.+)\.yml\z}, 1].split("_").map { inflector.camelize(it) }.join("/")
    content = File.read(t.source)

    department_content = content.each_line.slice_before {
      it.start_with?("# Department")
    }.find { it.first.include?("'#{department}'") }.join

    File.write(t.name, department_content)
  end

  desc "Generate base configuration"
  file "build/all.yml" => "build" do |t|
    options = %w[
      --force-default-config
      --display-cop-names
      --extra-details
      --display-style-guide
      --show-cops
    ].sort

    sh "bin/rubocop",
      *options,
      *plugin_names.sort.flat_map { %W[--plugin #{it}] },
      *extension_names.sort.flat_map { %W[--require #{it}] },
      out: t.name
  end
end
