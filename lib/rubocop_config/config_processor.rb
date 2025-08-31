# frozen_string_literal: true

require "uri"

module RubocopConfig
  class ConfigProcessor
    def initialize(plugin_names)
      @plugin_names = plugin_names
    end

    def process(content, department, gem_name, base)
      content = add_department_header(content, department)
      content = enable_all_cops(content)
      content = remove_deprecated_config(content)
      content = add_documentation_links(content, department, gem_name, base)
      content = normalize_paths(content)
      remove_trailing_whitespace(content)
    end

    private def add_department_header(content, department)
      cop_count = content.scan(%r{^#{Regexp.escape(department)}/}).length
      header = "# Department '#{department}' (#{cop_count}):\n"
      header + content
    end

    private def enable_all_cops(content)
      content.gsub(/(?<=^  )Enabled: (false|pending)$/) { "Enabled: true # was #{$1}" }
    end

    private def remove_deprecated_config(content)
      content.gsub(/^\s+AllowOnlyRestArgument:.*\n/, "")
    end

    private def add_documentation_links(content, department, gem_name, base)
      content.gsub(%r{(?=^#{department}/(.+):$)}) do
        cop_name = $1
        path = "/#{gem_name}/cops_#{base}.html"
        fragment = "#{department}#{cop_name}".downcase.delete("/_")

        "# #{URI::HTTPS.build(scheme: "https", host: "docs.rubocop.org", path:, fragment:)}\n"
      end
    end

    private def normalize_paths(content)
      content.gsub("#{Dir.pwd}/", "")
    end

    private def remove_trailing_whitespace(content)
      content.gsub(/ +$/, "")
    end
  end
end
