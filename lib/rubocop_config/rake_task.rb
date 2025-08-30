# frozen_string_literal: true

require "dry-inflector"
require "fileutils"
require "rake/tasklib"
require "rubocop"
require "rubocop-capybara"
require "rubocop-i18n"
require "rubocop-performance"
require "rubocop-rake"
require "rubocop-rspec"
require "rubocop-sequel"
require "rubocop-thread_safety"
require "uri"
require "yaml"

module RubocopConfig
  class RakeTask < Rake::TaskLib
    def initialize
      super()
      @inflector = Dry::Inflector.new do |inflections|
        inflections.acronym("RSpec")
        inflections.acronym("GetText")
        inflections.acronym("RailsI18n")
        inflections.acronym("ThreadSafety")
      end

      rubocop_gems = Gem::Specification.select { /\Arubocop-(?!ast$)/ =~ it.name }
      plugins, _ = rubocop_gems.partition { it.metadata["default_lint_roller_plugin"] }
      @plugin_names = plugins.map(&:name)
      @departments = RuboCop::Cop::Registry.global.map {|c| c.department.to_s }.sort.uniq

      define_tasks
    end

    private def define_tasks
      desc "Create defaults directory"
      directory "config/defaults"

      desc "Generate default configuration files"
      task generate_defaults: "config/defaults" do
        generate_all_default_configs
      end

      desc "Check cops configuration inheritance"
      task check_cops: :generate_defaults do
        check_cops_configurations
      end

      desc "Clean and regenerate all configuration files"
      task :regenerate do
        regenerate_all
      end

      # 部門別ファイル生成タスク
      @departments.each do |department|
        base = department.downcase.tr("/", "_")
        target_file = "config/defaults/#{base}.yml"

        desc "Generate configuration for #{department}"
        file target_file => "config/defaults" do |t|
          generate_default_config(department, t.name)
        end

        task generate_defaults: target_file
      end
    end

    private def generate_all_default_configs
      @departments.each do |department|
        base = department.downcase.tr("/", "_")
        target_file = "config/defaults/#{base}.yml"
        generate_default_config(department, target_file)
      end
    end

    private def generate_default_config(department, target_file)
      puts "Generating #{department} configuration..."

      base = department.downcase.tr("/", "_")
      gem_name = "rubocop-#{department.downcase.sub(%r{/.*}, "")}"
      gem_name = "rubocop" unless @plugin_names.include?(gem_name)

      options = [
        "--show-cops=#{department}/*",
        "--force-default-config",
        "--display-cop-names",
        "--extra-details",
        "--display-style-guide"
      ]

      cmd = [
        "bin/rubocop",
        *options,
        *@plugin_names.sort.flat_map { %W[--plugin #{it}] }
      ]

      puts "Running: #{cmd.join(" ")}"
      content = %x(#{cmd.join(" ")} 2>/dev/null)

      if $?.success?
        processed_content = post_process_config(content, department, gem_name, base)
        File.write(target_file, processed_content)
        puts "✓ Generated #{target_file}"
      else
        puts "✗ Failed to generate #{department} configuration"
        exit 1
      end
    end

    private def check_cops_configurations
      puts "Checking cops configurations..."

      Dir["config/defaults/*.yml"].each do |default_file|
        base_name = File.basename(default_file)
        cops_file = "config/cops/#{base_name}"

        next unless File.exist?(cops_file)

        puts "Checking #{cops_file}..."

        cops_content = File.read(cops_file)
        if cops_content.include?("inherit_from: ../defaults/#{base_name}")
          puts "  ✓ Inheritance looks good"
        else
          puts "  Warning: #{cops_file} may need inherit_from update"
        end
      end
    end

    private def regenerate_all
      puts "Cleaning existing defaults..."
      FileUtils.rm_rf("config/defaults")

      puts "Regenerating all configurations..."
      Rake::Task[:generate_defaults].invoke

      puts "Checking cops configurations..."
      Rake::Task[:check_cops].invoke

      puts "✓ Configuration regeneration complete!"
    end

    private def post_process_config(content, department, gem_name, base)
      # Count cops in this department
      cop_count = content.scan(%r{^#{Regexp.escape(department)}/}).length

      # Add department header
      header = "# Department '#{department}' (#{cop_count}):\n"
      content = header + content

      # Enable all cops (false/pending -> true)
      content.gsub!(/(?<=^  )Enabled: (false|pending)$/) { "Enabled: true # was #{$1}" }

      # Remove deprecated configuration
      content.gsub!(/^\s+AllowOnlyRestArgument:.*\n/, "")

      # Insert link to RuboCop documentation
      content.gsub!(%r{(?=^#{department}/(.+):$)}) do
        cop_name = $1
        path = "/#{gem_name}/cops_#{base}.html"
        fragment = "#{department}#{cop_name}".downcase.delete("/_")

        "# #{URI::HTTPS.build(scheme: "https", host: "docs.rubocop.org", path:, fragment:)}\n"
      end

      # Replace absolute path with relative path
      content.gsub!("#{Dir.pwd}/", "")

      # Remove trailing whitespace
      content.gsub!(/ +$/, "")

      content
    end
  end
end
