# Usage

1. Add this repo as a submodule named `.rubocop`
    ```sh
    git submodule add https://github.com/sakuro/rubocop-config .rubocop
    git submodule update --init
    ```
2. Include config files (`*.yml`) under `.rubocop` from your `.rubocop.yml` by using `inherit_from` directive.

You can generate `.rubocop.yml` by running: `rake -f .rubocop/Rakefile`.

```yaml
inherit_from:
  - .rubocop/bundler.yml
  - .rubocop/gemspec.yml
  - .rubocop/layout.yml
  - .rubocop/lint.yml
  - .rubocop/metrics.yml
  - .rubocop/naming.yml
  - .rubocop/performance.yml
  - .rubocop/rspec.yml
  - .rubocop/security.yml
  - .rubocop/style.yml
  - .rubocop_todo.yml

require:
  - rubocop-capybara
  - rubocop-factory_bot
  - rubocop-performance
  - rubocop-rake
  - rubocop-rspec

AllCops:
  EnabledByDefault: true
  TargetRubyVersion: <%= RUBY_VERSION.split(".")[0,2].join(".") %>
  Exclude:
    - bin/**/*
    - vendor/**/*
    - spec/spec_helper.rb
    - spec/support/rspec.rb
    - "*.gemspec"
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
