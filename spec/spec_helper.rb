# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
  track_files "lib/**/*.rb"
end

require "bundler/setup"
require "docquet"
require "fileutils"
require "tmpdir"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on Module and main
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Create temporary directories for file operations
  config.around do |example|
    Dir.mktmpdir do |dir|
      @temp_dir = dir
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  # Helper method to access temp directory in tests
  config.define_derived_metadata do |metadata|
    metadata[:temp_dir] = @temp_dir if @temp_dir
  end
end

# Helper methods for testing
def create_test_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
end

def create_test_config_structure
  FileUtils.mkdir_p("config/cops")
  FileUtils.mkdir_p("config/defaults")
end
