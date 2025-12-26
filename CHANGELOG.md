## [Unreleased]

## [1.2.0] - 2025-12-26

## [1.1.0] - 2025-11-30

### Changed
- Bump rubocop-rspec to 3.8.0
- Disabled some length and complexity cops
- Layout/FirstArrayElementIndentation and Layout/FirstHashElementIndentation now use "consistent" style

## [1.0.0] - 2025-11-02

### Added
- CLI tool with `install-config` and `regenerate-todo` commands
- Automatic RuboCop plugin detection using gem metadata
- Configuration generator for 18 RuboCop departments and plugins
- Support for core RuboCop departments (Style, Layout, Lint, Metrics, Security, Gemspec, Bundler, Naming)
- Support for RuboCop plugin extensions (Performance, RSpec, Capybara, I18n, Rake, Sequel, ThreadSafety, Migration)
- ERB-based configuration template system
- Ruby 3.2+ compatibility with Zeitwerk autoloading
- Dry::CLI framework integration for command-line interface

### Features
- Smart plugin detection based on installed gems
- Automatic `.rubocop_todo.yml` generation for gradual adoption
- Project-specific RuboCop configuration inheritance
- Force option for overwriting existing configuration files
- Ruby version detection from `.ruby-version` file or current Ruby version
