# frozen_string_literal: true

require "dry/cli"

module RubocopConfig
  module CLI
    class Base < Dry::CLI::Command
      protected

      def error(message)
        puts "Error: #{message}"
        exit 1
      end

      def success(message)
        puts "✓ #{message}"
      end

      def info(message)
        puts message
      end

      def rubocop_yml_exists?
        File.exist?(".rubocop.yml")
      end

      def bundle_exec_available?
        system("which bundle > /dev/null 2>&1")
      end
    end
  end
end