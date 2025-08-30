# RuboCop Config

This project provides a centralized RuboCop configuration to standardize code style across multiple Ruby projects. It's designed to be added as a Git submodule to maintain consistent coding standards.

## Overview

- **Purpose**: Standardize and share RuboCop configurations across multiple Ruby projects
- **Usage**: Add as a Git submodule to individual projects
- **Supported Plugins**: 
  - rubocop-capybara
  - rubocop-i18n
  - rubocop-performance
  - rubocop-rake
  - rubocop-rspec
  - rubocop-sequel
  - rubocop-thread_safety

## Configuration Structure

### Main Configuration
- `.rubocop.yml`: Main configuration file that integrates all settings

### Category-Specific Configurations
- `bundler.yml`: Bundler-related rules
- `capybara.yml`, `capybara_rspec.yml`: Capybara-related rules
- `gemspec.yml`: Gemspec-related rules
- `i18n_gettext.yml`, `i18n_railsi18n.yml`: Internationalization rules
- `layout.yml`: Layout and formatting rules
- `lint.yml`: Lint rules for potential bugs
- `metrics.yml`: Code complexity metrics
- `migration.yml`: Database migration rules
- `naming.yml`: Naming convention rules
- `performance.yml`: Performance optimization rules
- `rake.yml`: Rake-related rules
- `rspec.yml`: RSpec testing framework rules
- `security.yml`: Security-related rules
- `sequel.yml`: Sequel ORM rules
- `style.yml`: Code style rules
- `threadsafety.yml`: Thread safety rules

### Default Settings
The `default/` directory contains base configurations for each category. Customized configuration files inherit from these defaults and override specific settings.

## Usage

### 1. Add as a submodule

```sh
git submodule add https://github.com/sakuro/rubocop-config .rubocop.d
```

### 2. Configure your project's .rubocop.yml

#### Use all configurations
```yaml
inherit_from: .rubocop.d/.rubocop.yml
```

#### Use specific configurations only
```yaml
inherit_from:
  - .rubocop.d/style.yml
  - .rubocop.d/layout.yml
  - .rubocop.d/rspec.yml
```
# Cop Documentation

* rubocop core
  * [Bundler](https://docs.rubocop.org/rubocop/cops_bundler.html)
  * [Gemspec](https://docs.rubocop.org/rubocop/cops_gemspec.html)
  * [Layout](https://docs.rubocop.org/rubocop/cops_layout.html)
  * [Lint](https://docs.rubocop.org/rubocop/cops_lint.html)
  * [Metrics](https://docs.rubocop.org/rubocop/cops_metrics.html)
  * [Migration](https://docs.rubocop.org/rubocop/cops_migration.html)
  * [Naming](https://docs.rubocop.org/rubocop/cops_naming.html)
  * [Security](https://docs.rubocop.org/rubocop/cops_security.html)
  * [Style](https://docs.rubocop.org/rubocop/cops_style.html)
* rubocop-performance
  * [Performance](https://docs.rubocop.org/rubocop-performance/cops_performance.html)
* rubocop-rake
* rubocop-rspec
  * [Capybara](https://docs.rubocop.org/rubocop-rspec/cops_rspec_capybara.html)
  * [FactoryBot](https://docs.rubocop.org/rubocop-rspec/cops_rspec_factorybot.html)
  * [Rails](https://docs.rubocop.org/rubocop-rspec/cops_rspec_rails.html)
  * [RSpec](https://docs.rubocop.org/rubocop-rspec/cops_rspec.html)
