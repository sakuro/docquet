require "erb"

rubocop_yml = File.join(Rake.original_dir, ".rubocop.yml")

task default: rubocop_yml

file rubocop_yml do |t|
  readme = File.join(File.dirname(Rake.application.rakefile), "README.md")
  flag = false
  indent = nil
  lines = []
  File.read(readme).lines.each do |line|
    if !flag && /```yaml/ =~ line
      flag = true
      indent = /\A#{line.scan(/\A +/).first}/
    elsif flag && /```/ =~ line
      flag = false
    elsif flag
      lines << line.sub(indent, '')
    end
  end
  File.write(t.name, ERB.new(lines.join).result)
end

