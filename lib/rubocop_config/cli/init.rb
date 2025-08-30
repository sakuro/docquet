# frozen_string_literal: true

require_relative "base"
require_relative "../generators/rubocop_yml_generator"

module RubocopConfig
  module CLI
    class Init < Base
      desc "Initialize RuboCop configuration and generate TODO file"
      
      option :departments, type: :array, desc: "Specific departments to include (e.g., Style,Layout,RSpec)"
      option :force, type: :boolean, default: false, desc: "Overwrite existing files"
      option :skip_todo, type: :boolean, default: false, desc: "Skip TODO file generation"
      
      def call(departments: nil, force: false, skip_todo: false, **)
        check_existing_files(force)
        
        # 1. .rubocop.yml生成
        generator = Generators::RubocopYmlGenerator.new(departments: departments)
        generator.generate
        success "Generated .rubocop.yml"
        
        # 2. .rubocop_todo.yml生成
        unless skip_todo
          generate_todo_file
        end
        
        show_completion_message(skip_todo)
      end

      private

      def check_existing_files(force)
        existing_files = []
        existing_files << ".rubocop.yml" if File.exist?(".rubocop.yml")
        existing_files << ".rubocop_todo.yml" if File.exist?(".rubocop_todo.yml")
        
        if existing_files.any? && !force
          error "Files already exist: #{existing_files.join(', ')}. Use --force to overwrite."
        end
      end

      def generate_todo_file
        info "Generating .rubocop_todo.yml..."
        
        command = build_todo_command
        if system(command)
          success "Generated .rubocop_todo.yml"
        else
          error "Failed to generate .rubocop_todo.yml"
        end
      end

      def build_todo_command
        base_cmd = bundle_exec_available? ? "bundle exec rubocop" : "rubocop"
        "#{base_cmd} --auto-gen-config --no-exclude-limit --no-offense-counts --no-auto-gen-timestamp"
      end

      def show_completion_message(skip_todo)
        info ""
        info "✓ RuboCop setup complete!"
        info ""
        info "Next steps:"
        if skip_todo
          info "  1. Run 'rubocop-config regenerate-todo' to generate TODO file"
          info "  2. Run 'bundle exec rubocop' to check your code"
        else
          info "  1. Review .rubocop_todo.yml and gradually fix violations"
          info "  2. Use 'rubocop-config regenerate-todo' for future updates"
          info "  3. Run 'bundle exec rubocop' to check your code"
        end
      end
    end
  end
end