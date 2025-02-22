# frozen_string_literal: true

require "rake/clean"

CLEAN << FileList["build"]
CLOBBER << FileList["default"]

require "rubocop/rake_task"
RuboCop::RakeTask.new

Dir["#{__dir__}/tasks/*.rake"].each {|file| load file }
