# frozen_string_literal: true

module RubocopConfig
  # Detects available RuboCop plugins and provides consistent naming.
  #
  # Terminology:
  # - Plugin Gem Name: Full gem name (e.g., "rubocop-performance", "rubocop-rspec")
  # - Plugin Name: Short name without prefix (e.g., "performance", "rspec")
  #
  # Both forms are used in different contexts:
  # - Plugin Gem Names: For gem operations, --plugin CLI arguments
  # - Plugin Names: For config file matching, department filtering
  module PluginDetector
    # Returns full gem names of detected RuboCop plugins.
    #
    # @return [Array<String>] plugin gem names (e.g., ["rubocop-performance", "rubocop-rspec"])
    module_function def detect_plugin_gem_names
      plugins = Gem::Specification.select { /\ARuboCop::.*::Plugin\z/ =~ it.metadata["default_lint_roller_plugin"] }
      plugins.map(&:name)
    end

    # Returns short names of detected RuboCop plugins (without "rubocop-" prefix).
    #
    # @return [Array<String>] plugin names (e.g., ["performance", "rspec"])
    module_function def detect_plugin_names
      detect_plugin_gem_names.map {|name| name.delete_prefix("rubocop-") }
    end
  end
end
