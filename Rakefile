# frozen_string_literal: true

require "rake/clean"

CLOBBER << FileList["config/defaults"]

require "rubocop/rake_task"
RuboCop::RakeTask.new

require_relative "lib/rubocop_config/rake_task"

namespace :rubocop_config do
  RubocopConfig::RakeTask.new
end
