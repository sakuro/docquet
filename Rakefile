# frozen_string_literal: true

require "rake/clean"

CLEAN << FileList["build"]
CLOBBER << FileList["lib/rubocop_config/config/defaults"]

require "rubocop/rake_task"
RuboCop::RakeTask.new

if Dir.pwd == __dir__
  load "tasks/build.rake"      # Legacy build system
  load "tasks/gem_build.rake"  # New gem-compatible build system
else
  load File.join(__dir__, "tasks/config.rake")
  load File.join(__dir__, "tasks/rake_task.rake")
end
