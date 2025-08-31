# RuboCop Config Gem Development Plan

> **Note**: This document is preserved as historical material. The project was later renamed to `docquet`, but this document records the content from when it was initially planned as `sakuro-rubocop-config` / `rubocop-config`.

## Overview

Distribute the RuboCop configuration file collection currently operated as a submodule as a gem, providing CLI tools to improve usability.

## Goals

- Eliminate the complexity of submodule updates
- Simple setup and maintenance
- Maintain existing configuration management flow (Rake tasks)
- Unify configurations through version management

## Gem Design

### Naming Strategy

- **Gem name**: `sakuro-rubocop-config` (RubyGems registration name)
- **Executable file**: `rubocop-config` (command used by users)
- **Module name**: `RubocopConfig` (simple for independent tool)

### Project Structure

```
sakuro-rubocop-config/
├── sakuro-rubocop-config.gemspec
├── lib/
│   ├── rubocop_config.rb              # Entry point
│   └── rubocop_config/
│       ├── version.rb
│       ├── cli.rb                     # CLI registry
│       ├── cli/                       # Subcommand group
│       │   ├── base.rb               # Common functionality
│       │   ├── init.rb               # Initialization command
│       │   └── regenerate_todo.rb    # TODO regeneration command
│       ├── generators/               # File generation features
│       │   └── rubocop_yml_generator.rb
│       ├── config/                   # Configuration file group
│       │   ├── base.yml             # Main config (including plugin settings)
│       │   ├── cops/                # Customization settings
│       │   │   ├── bundler.yml
│       │   │   ├── style.yml
│       │   │   ├── layout.yml
│       │   │   ├── rspec.yml
│       │   │   └── ...
│       │   └── defaults/            # RuboCop default settings
│       │       ├── bundler.yml
│       │       ├── style.yml
│       │       └── ...
│       ├── config.rb                # Configuration management class
│       └── templates/
│           └── rubocop.yml.erb      # Project template
├── exe/
│   └── rubocop-config              # CLI executable
└── spec/                           # Tests
```

## CLI Design

### Framework

- **dry-cli**: Lightweight with few dependencies

### Command Structure

#### `rubocop-config init`
- Project initialization
- Generate `.rubocop.yml`
- Auto-generate `.rubocop_todo.yml` (`--auto-gen-config --no-exclude-limit --no-offense-counts --no-auto-gen-timestamp`)

**Options:**
- `--departments`: Specify only certain departments
- `--force`: Overwrite existing files
- `--skip-todo`: Skip TODO generation

#### `rubocop-config regenerate-todo`
- Regenerate `.rubocop_todo.yml`
- Simply execute `rubocop --regenerate-todo`

### Usage Flow

```bash
# 1. Installation
gem install sakuro-rubocop-config

# 2. Initial setup
cd my_project
rubocop-config init

# 3. TODO update after fixing violations
rubocop-config regenerate-todo
```

## Configuration File Management

### Inheritance Structure

```
base.yml
├── cops/style.yml (inherit_from: ../defaults/style.yml)
├── cops/layout.yml (inherit_from: ../defaults/layout.yml)
└── ...
```

### File Roles

1. **`config/base.yml`**: 
   - AllCops settings
   - Plugin settings
   - Inherits all files under cops/

2. **`config/cops/`**: 
   - Inherit from defaults/ and customize
   - Settings actually used by users
   - Override only necessary parts

3. **`config/defaults/`**: 
   - Base settings auto-generated from RuboCop
   - For reference during development and updates

### Usage in Projects

```yaml
# Basic usage
inherit_gem:
  sakuro-rubocop-config: config/base.yml

# Partial usage
inherit_gem:
  sakuro-rubocop-config:
    - config/cops/style.yml
    - config/cops/layout.yml
```

## Development & Maintenance Flow

### Gem Development Side (Configuration Maintenance)

```bash
# 1. When updating RuboCop version
bundle update rubocop rubocop-*

# 2. Update default settings (utilize existing Rake tasks)
bundle exec rake clobber
bundle exec rake build:all

# 3. Reflect in gem configuration files
cp default/*.yml lib/rubocop_config/config/defaults/

# 4. Check and adjust customization settings differences
# Manually adjust cops/ as needed

# 5. Gem version upgrade and release
gem build sakuro-rubocop-config.gemspec
gem push sakuro-rubocop-config-x.x.x.gem
```

### Build Task Modification Policy

#### Current Task Structure
- **`rake build:all`**: Overall task for generating all default settings
- **Generation flow**:
  1. Generate `build/all.yml` (bulk retrieve all cop information)
  2. Split into department-specific files (`default/bundler.yml`, etc.)

#### Efficiency Discovery
RuboCop's `--show-cops` supports department-specific specification:
```bash
# Department-wide specification (wildcards required)
bundle exec rubocop --show-cops 'Style/*' --force-default-config
bundle exec rubocop --show-cops 'Layout/*' --force-default-config

# Individual cop specification
bundle exec rubocop --show-cops Style/AccessModifierDeclarations --force-default-config
```

#### Improved Modification Plan
1. **Department-specific direct generation**: Generate each department individually without going through overall file
   ```ruby
   # Improvement proposal
   file "lib/rubocop_config/config/defaults/#{base}.yml" do |t|
     sh "bin/rubocop",
       "--show-cops", "'#{department}/*'",  # Department specification
       "--force-default-config",
       # Other options...
       out: t.name
   end
   ```

2. **Change output destination to gem structure**: `lib/rubocop_config/config/defaults/`
3. **Maintain inheritance relationships of customization settings**
4. **Add protection feature for existing cops files**  
5. **Difference reporting feature**

#### Benefits
- **Efficiency**: No intermediate files needed, reduced memory usage
- **Parallel processing**: Independent generation by department possible
- **Maintainability**: Each department independent, easy debugging

## gemspec Configuration

```ruby
Gem::Specification.new do |spec|
  spec.name          = "sakuro-rubocop-config"
  spec.version       = RubocopConfig::VERSION
  spec.authors       = ["OZAWA Sakuro"]
  
  spec.executables   = ["rubocop-config"]
  
  spec.add_dependency "rubocop", ">= 1.0"
  spec.add_dependency "dry-cli", "~> 1.0"
  spec.add_dependency "erb"
end
```

## Implementation Phases

### Phase 1: Foundation Building
- Create gem skeleton
- Implement CLI foundation
- Migrate configuration files

### Phase 2: Feature Implementation
- Implement init command
- Implement regenerate-todo command
- Set up tests

### Phase 3: Migration & Release
- Test in existing projects
- Prepare documentation
- Release gem

## Benefits

1. **Convenience**: One-command setup
2. **Maintainability**: Update configurations through gem updates
3. **Distribution**: No submodule management needed
4. **Compatibility**: Gradual migration possible
5. **Leverage existing assets**: Continue configuration management through Rake tasks

## Considerations

- Minimize impact on existing submodule users
- Maintain backward compatibility of configurations
- Inheritance relationship consistency check feature is important