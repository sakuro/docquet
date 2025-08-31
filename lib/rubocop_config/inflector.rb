# frozen_string_literal: true

require "dry/inflector"

module RubocopConfig
  # Provides a centralized inflector with consistent acronym rules.
  #
  # This module ensures all classes use the same inflection rules,
  # preventing inconsistencies in department name transformations.
  module Inflector
    # Returns a configured Dry::Inflector instance with custom acronyms.
    #
    # @return [Dry::Inflector] configured inflector instance
    def self.instance
      @instance ||= Dry::Inflector.new do |inflections|
        inflections.acronym("RSpec")
        inflections.acronym("GetText")
        inflections.acronym("RailsI18n")
      end
    end
  end
end
