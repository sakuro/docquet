# frozen_string_literal: true

require "rake/clean"

CLOBBER << FileList["config/defaults"]

require "rubocop/rake_task"
RuboCop::RakeTask.new

if Dir.pwd == __dir__
  require_relative "lib/rubocop_config/rake_task"
  
  namespace :rubocop_config do
    RubocopConfig::RakeTask.new
  end
else
  load File.join(__dir__, "tasks/config.rake")
  load File.join(__dir__, "tasks/rake_task.rake")
end
