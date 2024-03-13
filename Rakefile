require "erb"

task default: %w(.rubocop.yml .rubocop_todo.yml)

file ".rubocop.yml" do |t|
  readme = File.join(File.dirname(Rake.application.rakefile), "README.md")
  flag = false
  lines = []
  File.read(readme).lines.each do |line|
    if !flag && /```yaml/ =~ line
      flag = true
    elsif flag && /```/ =~ line
      flag = false
    elsif flag
      lines << line
    end
  end
  File.write(t.name, ERB.new(lines.join).result)
end

file ".rubocop_todo.yml" do |t|
  touch t.name
end
