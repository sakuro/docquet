# frozen_string_literal: true

module RubocopConfig
  class Config
    def self.base_config_path
      gem_config_path("base.yml")
    end
    
    def self.cops_config_path(category)
      gem_config_path("cops", "#{category}.yml")
    end
    
    def self.defaults_config_path(category)
      gem_config_path("defaults", "#{category}.yml")
    end
    
    def self.template_path(template)
      File.join(__dir__, "templates", template)
    end
    
    def self.available_categories
      Dir[gem_config_path("cops", "*.yml")]
        .map { |path| File.basename(path, ".yml") }
        .sort
    end
    
    def self.validate_inheritance
      # cops/ の各ファイルが対応する defaults/ ファイルを継承しているかチェック
      available_categories.each do |category|
        cops_file = cops_config_path(category)
        next unless File.exist?(cops_file)
        
        content = File.read(cops_file)
        unless content.include?("inherit_from: ../defaults/#{category}.yml")
          warn "Warning: #{cops_file} does not inherit from defaults/#{category}.yml"
        end
      end
    end
    
    private
    
    def self.gem_config_path(*paths)
      File.join(__dir__, "config", *paths)
    end
  end
end