# frozen_string_literal: true

desc "Generate a Rake task for RuboCop"
task :rake_task, :rake_file_path do |_task, args|
  output_path = args.rake_file_path || "lib/tasks/rubocop.rake"
  content = <<~RAKE_TASK
    require "rubocop/rake_task"
    RuboCop::RakeTask.new

    namespace :rubocop do
      desc "Regenerate RuboCop TODO file"
      RuboCop::RakeTask.new(:regenerate_todo) do |task|
        task.options << "--regenerate-todo"
      end
    end
  RAKE_TASK

  if File.exist?(output_path)
    File.write(output_path, "\n#{content}", mode: "a")
  else
    mkdir_p File.dirname(output_path)
    magic_comment = "# frozen_string_literal: true"
    File.write(output_path, "#{magic_comment}\n\n#{content}")
  end
end
