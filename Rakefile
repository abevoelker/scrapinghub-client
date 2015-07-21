require "rspec"
require "rspec/core/rake_task"
require "rake/testtask"
require "bundler"

Rake::TestTask.new("spec:unit") do |t|
  t.libs << ["lib", "spec"]
  t.pattern = "spec/unit/**/*spec.rb"
end

RSpec::Core::RakeTask.new("spec:integration") do |t|
  t.pattern = "spec/integration/**/*spec.rb"
end

Rake::TestTask.new("spec") do |t|
  t.libs << ["lib", "spec"]
  t.pattern = "spec/**/*spec.rb"
end

task :default => "spec"

Bundler::GemHelper.install_tasks
