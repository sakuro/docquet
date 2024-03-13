require "erb"

task default: %w(.rubocop.yml .rubocop_todo.yml)

file ".rubocop.yml" do |t|
  readme = File.join(File.dirname(Rake.application.rakefile), "README.md")
  content =
    File.read(readme)
      .each_line
      .drop_while {|line| /\A```yaml/ !~ line }
      .drop(1)
      .take_while {|line| /\A```/ !~ line }
      .join
  File.write(t.name, ERB.new(content).result)
end

file ".rubocop_todo.yml" do |t|
  touch t.name
end
