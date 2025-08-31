# RuboCop Config

A standardized RuboCop configuration gem that automatically detects available RuboCop plugins and generates appropriate configurations with CLI tools for easy setup and maintenance.

## Features

- **Automatic Plugin Detection**: Automatically detects installed RuboCop plugins and includes their configurations
- **CLI Tools**: Easy-to-use commands for initialization and maintenance
- **Comprehensive Coverage**: Supports all major RuboCop plugins out of the box
- **Documentation Links**: Generated configurations include links to official documentation
- **Incremental Setup**: Generates `.rubocop_todo.yml` for gradual adoption

## Installation

### As a Gem

```bash
gem install sakuro-rubocop-config
```

Or add it to your Gemfile:

```ruby
gem "sakuro-rubocop-config", require: false
```

## Usage

### Initialize RuboCop Configuration

Run the initialization command in your project root:

```bash
rubocop-config init
```

This command will:
1. Generate `.rubocop.yml` with configurations for detected plugins
2. Create an initial `.rubocop_todo.yml` with existing violations
3. Display next steps for gradual adoption

To overwrite existing files:

```bash
rubocop-config init --force
```

### Update TODO File

When you've fixed some violations and want to regenerate the TODO file:

```bash
rubocop-config regenerate-todo
```

This command will:
- Regenerate `.rubocop_todo.yml` with current violations
- Show whether the TODO file changed
- Provide feedback on progress

## Supported RuboCop Plugins

The gem automatically detects and configures the following plugins when installed:

### Core RuboCop
- **Bundler**: Bundler-related rules
- **Gemspec**: Gemspec file rules  
- **Layout**: Code formatting and layout rules
- **Lint**: Rules for catching potential bugs
- **Metrics**: Code complexity and size metrics
- **Naming**: Naming convention rules
- **Security**: Security-related rules
- **Style**: General code style rules

### Plugin Extensions
- **rubocop-capybara**: Capybara testing framework rules
- **rubocop-i18n**: Internationalization rules (GetText, Rails I18n)
- **rubocop-performance**: Performance optimization rules
- **rubocop-rake**: Rake task rules
- **rubocop-rspec**: RSpec testing framework rules
- **rubocop-sequel**: Sequel ORM rules
- **rubocop-thread_safety**: Thread safety rules

## Generated Configuration Structure

The generated `.rubocop.yml` file includes:

```yaml
TargetRubyVersion: 3.1  # Detected from .ruby-version or current Ruby

inherit_from:
  - config/cops/style.yml        # Core style rules
  - config/cops/layout.yml       # Core layout rules
  - config/cops/performance.yml  # Performance rules (if plugin detected)
  - config/cops/rspec.yml        # RSpec rules (if plugin detected)
  # ... other detected plugins
```

Each configuration file includes:
- Department-specific rules with counts
- Links to official RuboCop documentation
- Enabled cops with descriptive comments
- Optimized settings for practical use

## Configuration Philosophy

This configuration aims to:

1. **Enforce Consistency**: Standardize code style across projects
2. **Promote Best Practices**: Enable rules that catch common issues
3. **Provide Documentation**: Include links to understand each rule
4. **Enable Gradual Adoption**: Use TODO files for incremental improvements
5. **Stay Current**: Automatically adapt to installed plugin versions

## Development

### Running Tests

```bash
bundle exec rspec
```

### Running RuboCop

```bash
bundle exec rubocop
```

### Regenerating TODO File

```bash
./exe/rubocop-config regenerate-todo
```

## Documentation Links

### Core RuboCop
- [Bundler Cops](https://docs.rubocop.org/rubocop/cops_bundler.html)
- [Gemspec Cops](https://docs.rubocop.org/rubocop/cops_gemspec.html)  
- [Layout Cops](https://docs.rubocop.org/rubocop/cops_layout.html)
- [Lint Cops](https://docs.rubocop.org/rubocop/cops_lint.html)
- [Metrics Cops](https://docs.rubocop.org/rubocop/cops_metrics.html)
- [Naming Cops](https://docs.rubocop.org/rubocop/cops_naming.html)
- [Security Cops](https://docs.rubocop.org/rubocop/cops_security.html)
- [Style Cops](https://docs.rubocop.org/rubocop/cops_style.html)

### Plugin Extensions  
- [Performance Cops](https://docs.rubocop.org/rubocop-performance/cops_performance.html)
- [RSpec Cops](https://docs.rubocop.org/rubocop-rspec/cops_rspec.html)
- [RSpec Capybara Cops](https://docs.rubocop.org/rubocop-rspec/cops_rspec_capybara.html)
- [RSpec FactoryBot Cops](https://docs.rubocop.org/rubocop-rspec/cops_rspec_factorybot.html)  
- [RSpec Rails Cops](https://docs.rubocop.org/rubocop-rspec/cops_rspec_rails.html)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run the test suite: `bundle exec rspec`  
5. Run RuboCop: `bundle exec rubocop`
6. Submit a pull request

## License

This gem is available as open source under the terms of the [MIT License](LICENSE).