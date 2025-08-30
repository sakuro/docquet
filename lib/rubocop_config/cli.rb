# frozen_string_literal: true

require "dry/cli"
require_relative "cli/init"
require_relative "cli/regenerate_todo"

module RubocopConfig
  module Commands
    extend Dry::CLI::Registry

    register "init", CLI::Init
    register "regenerate-todo", CLI::RegenerateTodo
  end
end
