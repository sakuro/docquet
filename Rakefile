# frozen_string_literal: true

require "rake/clean"
require "uri/https"

CLEAN << "default.yml"
CLOBBER << FileList["default"]

Dir["tasks/*.rake"].each {|file| load file }
