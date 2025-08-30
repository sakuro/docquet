# frozen_string_literal: true

require "dry/cli"

module RubocopConfig
  module CLI
    class Base < Dry::CLI::Command
      private def rubocop_yml_exists?
        File.exist?(".rubocop.yml")
      end

      private def rubocop_command
        bundle_exec_available? ? "bundle exec rubocop" : "rubocop"
      end

      private def bundle_exec_available?
        system("which bundle > /dev/null 2>&1")
      end
    end
  end
end