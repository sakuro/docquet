# frozen_string_literal: true

# Configuration only; SimpleCov.start is called from spec/spec_helper.rb.
SimpleCov.configure do
  skip "/spec/"
  skip "/vendor/"
  skip "/examples/"

  group "Library", "lib"

  minimum_coverage 90.0
  enable_coverage :branch

  formats :html, :simple

  merge_timeout 3600
end
