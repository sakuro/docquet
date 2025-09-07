# frozen_string_literal: true

require "dry/cli"
require_relative "cli/install_config"
require_relative "cli/regenerate_todo"

module Docquet
  module Commands
    extend Dry::CLI::Registry

    register "install-config", CLI::InstallConfig
    register "regenerate-todo", CLI::RegenerateTodo
  end
end
