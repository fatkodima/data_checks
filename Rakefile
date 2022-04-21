# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

rubocop_exists = false
begin
  require "rubocop/rake_task"
  rubocop_exists = true
rescue LoadError
  # Older version of ruby and active_record.
end

if rubocop_exists
  RuboCop::RakeTask.new
  task default: [:rubocop, :test]
else
  task default: :test
end
