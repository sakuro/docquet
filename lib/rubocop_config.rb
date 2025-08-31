# frozen_string_literal: true

require_relative "rubocop_config/cli"
require_relative "rubocop_config/cli/base"
require_relative "rubocop_config/cli/init"
require_relative "rubocop_config/cli/regenerate_todo"
require_relative "rubocop_config/config_processor"
require_relative "rubocop_config/generators/rubocop_yml_generator"
require_relative "rubocop_config/rake_task"
require_relative "rubocop_config/version"

module RubocopConfig
  class Error < StandardError; end
end
