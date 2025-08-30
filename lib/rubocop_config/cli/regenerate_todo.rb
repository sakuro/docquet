# frozen_string_literal: true

require_relative "base"

module RubocopConfig
  module CLI
    class RegenerateTodo < Base
      desc "Regenerate .rubocop_todo.yml"
      
      def call(**)
        unless rubocop_yml_exists?
          puts "Error: .rubocop.yml not found. Run 'rubocop-config init' first."
          exit 1
        end

        command = build_command
        
        puts "Running: #{command}"
        if system(command)
          puts <<~MESSAGE
            ✓ Regenerated .rubocop_todo.yml
            Review the updated TODO file and continue fixing violations.
          MESSAGE
        else
          puts "Error: Failed to regenerate .rubocop_todo.yml"
          exit 1
        end
      end

      private def build_command
        "#{rubocop_command} --regenerate-todo --no-exclude-limit --no-offense-counts --no-auto-gen-timestamp"
      end
    end
  end
end