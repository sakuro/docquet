# frozen_string_literal: true

require "dry-inflector"
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
require "fileutils"

def post_process_config(content, department, gem_name, base)
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
  
  content
end

namespace :gem do
  inflector = Dry::Inflector.new do |inflections|
    inflections.acronym("RSpec")
    inflections.acronym("GetText")
    inflections.acronym("RailsI18n")
    inflections.acronym("ThreadSafety")
  end

  rubocop_gems = Gem::Specification.select { /\Arubocop-(?!ast$)/ =~ it.name }
  plugins, extensions = rubocop_gems.partition { it.metadata["default_lint_roller_plugin"] }
  plugin_names = plugins.map(&:name)
  extension_names = extensions.map(&:name)
  departments = RuboCop::Cop::Registry.global.map {|c| c.department.to_s }
  departments.sort!
  departments.uniq!

  desc "Generate all gem configuration files"
  task :config => "config/defaults"

  desc "Create defaults directory"
  directory "config/defaults"

  # 部門別直接生成タスク
  departments.each do |department|
    base = department.downcase.tr("/", "_")
    gem_name = "rubocop-#{department.downcase.sub(%r{/.*}, "")}"
    gem_name = "rubocop" unless plugin_names.include?(gem_name) || extension_names.include?(gem_name)
    
    target_file = "config/defaults/#{base}.yml"
    
    desc "Generate configuration for #{department}"
    file target_file => "config/defaults" do |t|
      puts "Generating #{department} configuration..."
      
      # 部門別直接生成
      options = %w[
        --show-cops
        --force-default-config
        --display-cop-names
        --extra-details
        --display-style-guide
      ]
      
      # コマンド実行
      cmd = [
        "bin/rubocop",
        *options,
        *plugin_names.sort.flat_map { %W[--plugin #{it}] },
        *extension_names.sort.flat_map { %W[--require #{it}] },
        "'#{department}/*'"
      ]
      
      puts "Running: #{cmd.join(" ")}"
      content = `#{cmd.join(" ")} 2>/dev/null`
      
      if $?.success?
        # 後処理
        processed_content = post_process_config(content, department, gem_name, base)
        File.write(t.name, processed_content)
        puts "✓ Generated #{t.name}"
      else
        puts "✗ Failed to generate #{department} configuration"
        exit 1
      end
    end
    
    # メインタスクに依存関係追加
    task "gem:config" => target_file
  end

  desc "Update cops configurations based on new defaults"
  task :update_cops => "gem:config" do
    puts "Updating cops configurations..."
    
    Dir["config/defaults/*.yml"].each do |default_file|
      base_name = File.basename(default_file)
      cops_file = "config/cops/#{base_name}"
      
      next unless File.exist?(cops_file)
      
      puts "Checking #{cops_file}..."
      
      # 継承関係の確認
      cops_content = File.read(cops_file)
      unless cops_content.include?("inherit_from: ../defaults/#{base_name}")
        puts "  Warning: #{cops_file} may need inherit_from update"
      else
        puts "  ✓ Inheritance looks good"
      end
    end
  end

  desc "Clean and regenerate all configuration files"
  task :regenerate do
    puts "Cleaning existing defaults..."
    FileUtils.rm_rf("config/defaults")
    
    puts "Regenerating all configurations..."
    Rake::Task["gem:config"].invoke
    
    puts "Updating cops configurations..."
    Rake::Task["gem:update_cops"].invoke
    
    puts "✓ Configuration regeneration complete!"
  end
end