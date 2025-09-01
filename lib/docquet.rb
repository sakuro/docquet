# frozen_string_literal: true

require_relative "docquet/cli"
require_relative "docquet/cli/base"
require_relative "docquet/cli/init"
require_relative "docquet/cli/regenerate_todo"
require_relative "docquet/config_processor"
require_relative "docquet/generators/rubocop_yml_generator"
require_relative "docquet/inflector"
# require_relative "docquet/rake_task" # Disabled to avoid loading all RuboCop plugins when using docquet command in other projects
require_relative "docquet/version"

module Docquet
  class Error < StandardError; end
end
