# frozen_string_literal: true

require "dry/cli"

module Docquet
  module Commands
    extend Dry::CLI::Registry

    register "install-config", CLI::InstallConfig
    register "regenerate-todo", CLI::RegenerateTodo
  end
end