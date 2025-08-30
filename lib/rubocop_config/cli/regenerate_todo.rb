# frozen_string_literal: true

require_relative "base"

module RubocopConfig
  module CLI
    class RegenerateTodo < Base
      desc "Regenerate .rubocop_todo.yml"
      
      def call(**)
        unless rubocop_yml_exists?
          error ".rubocop.yml not found. Run 'rubocop-config init' first."
        end

        command = build_command
        
        info "Running: #{command}"
        if system(command)
          success "Regenerated .rubocop_todo.yml"
          info "Review the updated TODO file and continue fixing violations."
        else
          error "Failed to regenerate .rubocop_todo.yml"
        end
      end

      private

      def build_command
        base_cmd = bundle_exec_available? ? "bundle exec rubocop" : "rubocop"
        "#{base_cmd} --regenerate-todo"
      end
    end
  end
end