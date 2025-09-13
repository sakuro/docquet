# Repository Guidelines

> **Note**: This file is also accessible via the `CLAUDE.md` symlink for AI agent compatibility.

> **Critical**: This document references other documentation files. You MUST read and follow:
> - `docs/agents/rubocop.md` - RuboCop fix guidelines for AI agents
> - `docs/agents/git-pr.md` - Git commit and pull request guidelines
> - `docs/agents/languages.md` - Language usage guidelines for communication and code
> - Any other documents referenced inline below

## Project Structure & Module Organization
- `lib/docquet`: Core library. Entry point is `lib/docquet.rb`; code is namespaced under `Docquet` (autoloaded via Zeitwerk).
- `spec`: RSpec tests. Mirror library paths (e.g., `spec/docquet/cli_spec.rb`).
- `config/cops`: RuboCop configuration files for different departments.
- `config/defaults`: Default configurations for RuboCop departments.
- `templates`: ERB templates for generating configuration files.
- `exe`: Executable files (`exe/docquet`).

## Build, Test, and Development Commands
- `bundle install`: Install dependencies (use a supported Ruby; see policy below and `mise.toml`).
- `bundle exec rspec`: Run the test suite.
- `bundle exec rubocop`: Lint and style checks.
- `./exe/docquet install-config`: Generate .rubocop.yml and .rubocop_todo.yml files.
- `./exe/docquet regenerate-todo`: Regenerate `.rubocop_todo.yml` after lint updates; include with related code fixes.
- `bin/console`: IRB with the gem loaded for quick experiments.

## Communication & Languages
See `docs/agents/languages.md` for detailed language usage guidelines covering:
- AI/user chat communication languages
- Source code and documentation language requirements  
- Issues/PRs language preferences
- Context-appropriate language switching

## Coding Style & Naming Conventions
- Ruby 3.2+ compatible; 2-space indent, `# frozen_string_literal: true` headers.
- Follow RuboCop rules (`.rubocop.yml`); fix offenses before committing.
- Files and specs use snake_case; specs live under `spec/docquet/*_spec.rb`.
- Public API is under `Docquet`; avoid monkey patching. Prefer clear, simple design patterns.
- CLI commands use `Dry::CLI` framework with clear separation of concerns.
- RuboCop fixes: When addressing lints, follow `docs/agents/rubocop.md` (safe autocorrect first; targeted unsafe only as needed).

## Testing Guidelines
- Framework: RSpec with `spec_helper` and SimpleCov. Maintain ≥ 90% coverage.
- Name/spec files to mirror library paths; keep examples focused and readable.
- Run `bundle exec rspec` locally; ensure `.rspec_status` is clean.
- SimpleCov configuration is in `.simplecov` file.
- Use `output(...).to_stdout` matchers for CLI testing, not manual capture.
- Group error handling tests within appropriate class specs, not separate files.

## Commit & Pull Request Guidelines
- Title format: Must start with a GitHub `:emoji:` code followed by a space, then an imperative subject. Example: `:zap: Optimize Style#call path`.
- No raw emoji: Use `:emoji:` codes only (commit hook rejects Unicode emoji).
- Exceptions: `fixup!` / `squash!` are allowed by hooks.
- Merge commits: Auto-prefixed with `:inbox_tray:` by the prepare-commit-msg hook.
- Commit body: English, explaining motivation, approach, and trade-offs.
- Include rationale and, when useful, before/after snippets or benchmarks.
- Link issues (e.g., `Fixes #123`) and update README/CHANGELOG when user-facing behavior changes.
- PRs must pass `bundle exec rspec` and `bundle exec rubocop`, include tests for changes.

## Security & Configuration Tips
- Supported Ruby: latest patch of the newest three minor series (e.g., 3.4.x / 3.3.x / 3.2.x). Develop locally on the oldest of these.
- Version management: Use `mise`; the repo's `mise.toml` sets the default to the oldest supported series. Examples: `mise use -g ruby@3.2`, `mise run -e ruby@3.3 bundle exec rspec`.
- Keep runtime dependencies minimal; prefer standard library where possible.
- No network access is expected at runtime; avoid introducing it without discussion.
