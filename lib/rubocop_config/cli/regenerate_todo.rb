# frozen_string_literal: true

require "digest"
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

        before_hash = calculate_file_hash(".rubocop_todo.yml")
        command = build_command

        puts "Running: #{command}"
        if system(command)
          after_hash = calculate_file_hash(".rubocop_todo.yml")
          changed = before_hash != after_hash

          puts <<~MESSAGE
            ✓ Regenerated .rubocop_todo.yml
            #{changed ? "📝 TODO file was updated with changes" : "✅ TODO file unchanged (no new violations)"}
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

      private def calculate_file_hash(file_path)
        return nil unless File.exist?(file_path)

        Digest::SHA256.hexdigest(File.read(file_path))
      end
    end
  end
end
