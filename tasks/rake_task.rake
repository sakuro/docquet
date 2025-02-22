# frozen_string_literal: true

desc "Generate a Rake task for RuboCop"
task :rake_task, :rake_file_path do
  content = <<~RAKE_TASK
    # frozen_string_literal: true

    require "rubocop/rake_task"

    RuboCop::RakeTask.prepend(Module.new do
      def setup_subtasks(name, *args, &task_block)
        super
        namespace name do
          desc "Regenerate RuboCop TODO file"
          task(:regenerate_todo, *args) do |_, task_args|
            RakeFileUtils.verbose(verbose) do
              yield(*[self, task_args].slice(0, task_block.arity)) if task_block
              perform('--regenerate-todo')
            end
          end
        end
      end
    end)

    RuboCop::RakeTask.new
  RAKE_TASK

  mkdir_p "lib/tasks"
  File.write("lib/tasks/rubocop.rake", content)
end
