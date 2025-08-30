# frozen_string_literal: true

require_relative "lib/rubocop_config/version"

Gem::Specification.new do |spec|
  spec.name          = "sakuro-rubocop-config"
  spec.version       = RubocopConfig::VERSION
  spec.authors       = ["OZAWA Sakuro"]
  spec.email         = ["10973+sakuro@users.noreply.github.com"]

  spec.summary       = "Standardized RuboCop configuration with CLI tools"
  spec.description   = "Provides opinionated RuboCop configurations and CLI tools for easy setup and maintenance"
  spec.homepage      = "https://github.com/sakuro/rubocop-config"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path(__dir__)) {
    %x(git ls-files -z).split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "rubocop", ">= 1.0"
  spec.add_dependency "dry-cli", "~> 1.0"
  spec.add_dependency "erb"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
