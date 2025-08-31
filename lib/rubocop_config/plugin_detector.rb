# frozen_string_literal: true

module RubocopConfig
  module PluginDetector
    module_function def detect_rubocop_plugins
      rubocop_gems = Gem::Specification.select { /\Arubocop-(?!ast\z)/ =~ it.name }
      plugins = rubocop_gems.select { it.metadata["default_lint_roller_plugin"] }
      plugins.map(&:name)
    end

    module_function def detect_plugin_names
      detect_rubocop_plugins.map {|name| name.delete_prefix("rubocop-") }
    end
  end
end
