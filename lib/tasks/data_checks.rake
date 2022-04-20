# frozen_string_literal: true

namespace :data_checks do
  desc "Run checks"
  task :run_checks, [:tag] => :environment do |_, args|
    runner = DataChecks::Runner.new
    runner.run_checks(tag: args[:tag] || ENV["TAG"])
  end

  desc "Show statuses of all checks"
  task status: :environment do
    printer = DataChecks::StatusPrinter.new
    printer.print
  end
end
