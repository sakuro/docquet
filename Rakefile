# frozen_string_literal: true

require "rake/clean"
require "uri/https"

CLEAN << "default.yml"
CLOBBER << FileList["default"]

plugins = %w[performance rake].sort
requires = %w[capybara i18n rspec rspec sequel thread_safety].sort

desc "Generate default configuration with details"
file "default.yml" do |t|
  options = %w[
    --force-default-config
    --display-cop-names
    --extra-details
    --display-style-guide
    --show-cops
  ].sort

  sh "bin/rubocop",
    *options,
    *plugins.flat_map {|plugin| %W[--plugin rubocop-#{plugin}] },
    *requires.flat_map {|require| %W[--require rubocop-#{require}] },
    out: t.name
end

directory "default"

desc "Split default configuration by department"
task split: %w[default.yml default] do |t|
  sh "csplit", t.prerequisites[0], "/^# Department/", "{*}", "--prefix=default-"
  Dir["default-*"].each do |file|
    content = File.read(file)

    if /^# Department '(.+)' \(\d+\):$/ =~ content
      department = $1

      # Enable all cops
      content.gsub!(/(?<=^  )Enabled: (false|pending)$/) { "Enabled: true # was #{$1}" }

      # Insert link to RuboCop documentation
      content.gsub!(%r{(?=^#{department}/(.+):$)}) do
        cop_name = $1
        gem_name =
          if (plugins + requires).include?(department.downcase.sub(%r{/.*}, ""))
            "rubocop-#{department.downcase.sub(%r{/.*}, "")}"
          else
            "rubocop"
          end
        path = "/#{gem_name}/cops_#{department.downcase.tr("/", "_")}.html"
        fragment = "#{department}#{cop_name}".downcase.delete("/_")

        "# #{URI::HTTPS.build(scheme: "https", host: "docs.rubocop.org", path:, fragment:)}\n"
      end

      file_name = "default/#{department.downcase.tr("/", "_")}.yml"
      File.write(file_name, content)
    end
    rm_f file
  end
end
