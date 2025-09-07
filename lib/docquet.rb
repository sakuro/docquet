# frozen_string_literal: true

require "zeitwerk"
require_relative "docquet/version"

module Docquet
  class Error < StandardError; end

  loader = Zeitwerk::Loader.for_gem
  loader.inflector.inflect(
    "cli" => "CLI",
    "rubocop_yml_generator" => "RuboCopYMLGenerator"
  )
  loader.ignore("#{__dir__}/docquet/version.rb")
  loader.ignore("#{__dir__}/docquet/rake_task.rb")
  loader.setup
end
