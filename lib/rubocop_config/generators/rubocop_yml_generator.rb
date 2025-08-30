# frozen_string_literal: true

require "erb"

module RubocopConfig
  module Generators
    class RubocopYmlGenerator
      def initialize
        @detected_plugins = detect_rubocop_plugins
        @filtered_configs = filtered_config_files
      end

      def generate
        content = ERB.new(File.read(template_path("rubocop.yml.erb")), trim_mode: "-").result(binding)
        File.write(".rubocop.yml", content)
      end

      private def detected_ruby_version
        # Detect from .ruby-version or Gemfile
        if File.exist?(".ruby-version")
          File.read(".ruby-version").strip
        else
          RUBY_VERSION[/\A\d+\.\d+/]
        end
      end

      private def template_path(filename)
        File.join(File.dirname(__dir__, 3), "templates", filename)
      end

      private def detect_rubocop_plugins
        rubocop_gems = Gem::Specification.select {|spec|
          /\Arubocop-(?!ast\z)/ =~ spec.name &&
            spec.metadata["default_lint_roller_plugin"]
        }
        rubocop_gems.map {|spec| spec.name.delete_prefix("rubocop-") }
      end

      private def detect_available_config_files
        gem_config_dir = File.join(File.dirname(__dir__, 3), "config", "cops")
        Dir.glob("#{gem_config_dir}/*.yml").map {|path| File.basename(path, ".yml") }
      end

      private def filtered_config_files
        available_configs = detect_available_config_files
        core_departments = %w[style layout lint metrics security gemspec bundler naming]

        available_configs.select do |config|
          # Extract department name from config file name
          department = extract_department_from_config(config)

          if core_departments.include?(department.downcase)
            true # Core departments are always included
          else
            # Check if corresponding plugin is detected
            plugin_name = department.downcase
            @detected_plugins.include?(plugin_name)
          end
        end
      end

      private def extract_department_from_config(config)
        # Convert config file name to department
        # "capybara_rspec" → "capybara", "i18n_gettext" → "i18n"
        config.split("_").first
      end
    end
  end
end
