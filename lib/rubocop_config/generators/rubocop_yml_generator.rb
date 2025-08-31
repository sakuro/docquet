# frozen_string_literal: true

require "dry-inflector"
require "erb"
require_relative "../plugin_detector"

module RubocopConfig
  module Generators
    class RubocopYmlGenerator
      def initialize
        @inflector = Dry::Inflector.new do |inflections|
          inflections.acronym("RSpec")
          inflections.acronym("GetText")
          inflections.acronym("RailsI18n")
        end
        @detected_plugin_names = PluginDetector.detect_plugin_names
        @detected_plugins = @detected_plugin_names # For template compatibility
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

          if core_departments.include?(@inflector.underscore(department))
            true # Core departments are always included
          else
            # Check if corresponding plugin is detected
            plugin_name = @inflector.underscore(department)
            @detected_plugin_names.include?(plugin_name)
          end
        end
      end

      private def extract_department_from_config(config)
        # Extract department name from the corresponding defaults file
        cops_file = File.join(File.dirname(__dir__, 3), "config", "cops", "#{config}.yml")
        
        if File.exist?(cops_file)
          cops_content = File.read(cops_file)
          if cops_content =~ /inherit_from:\s*\.\.\/defaults\/(.+)\.yml/
            defaults_file = File.join(File.dirname(__dir__, 3), "config", "defaults", "#{$1}.yml")
            
            if File.exist?(defaults_file)
              defaults_content = File.read(defaults_file)
              if defaults_content =~ /^# Department '(.+)'/
                return $1
              end
            end
          end
        end
        
        # Fallback: use the simple split method
        config.split("_").first
      end
    end
  end
end
