# frozen_string_literal: true

require "rake/clean"

CLEAN << FileList["build"]
CLOBBER << FileList["default"]

require "rubocop/rake_task"
RuboCop::RakeTask.new

if Dir.pwd == __dir__
  load "tasks/build.rake"
else
  load File.join(__dir__, "tasks/config.rake")
  load File.join(__dir__, "tasks/rake_task.rake")
end
