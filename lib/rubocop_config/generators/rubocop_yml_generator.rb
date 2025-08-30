# frozen_string_literal: true

require "erb"
require_relative "../config"

module RubocopConfig
  module Generators
    class RubocopYmlGenerator
      def initialize(departments: nil)
        @departments = departments
      end

      def generate
        template_path = Config.template_path("rubocop.yml.erb")
        content = ERB.new(File.read(template_path)).result(binding)
        File.write(".rubocop.yml", content)
      end

      private

      def detected_ruby_version
        # .ruby-version や Gemfile から検出
        if File.exist?(".ruby-version")
          File.read(".ruby-version").strip
        else
          RUBY_VERSION[/\d+\.\d+/]
        end
      end

      def inherit_config
        if @departments
          @departments.map { |dep| "cops/#{dep.downcase}.yml" }
        else
          "base.yml"
        end
      end
    end
  end
end