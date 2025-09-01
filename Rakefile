# frozen_string_literal: true

require "rake/clean"

CLEAN.include("coverage", ".rspec_status")
CLOBBER << FileList["config/defaults"]

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require_relative "lib/docquet/rake_task"

task default: %i[spec rubocop]

namespace :docquet do
  Docquet::RakeTask.new
end
