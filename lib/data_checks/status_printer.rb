# frozen_string_literal: true

module DataChecks
  class StatusPrinter
    def initialize(io = $stdout)
      @io = io
    end

    def print
      runs = DataChecks::CheckRun.all.to_a
      counts = Hash.new { |h, k| h[k] = 0 }

      DataChecks.config.checks.each do |check|
        run = runs.find { |r| r.name == check.name }

        if run
          counts[run.status] += 1

          formatted_time = run.last_run_at.to_formatted_s(:db)
          @io.puts("Check #{check.name} (at #{formatted_time}) - #{run.status.titleize}")
        else
          counts["not_ran"] += 1
          @io.puts("Check #{check.name} - Not ran yet")
        end
      end

      @io.puts
      print_summary(counts)
    end

    private
      def print_summary(counts)
        statuses = DataChecks::CheckRun.statuses
        summary = "Error: #{counts[statuses[:error]]}, " \
                  "Failing: #{counts[statuses[:failing]]}, " \
                  "Passing: #{counts[statuses[:passing]]}"
        summary += ", Not Ran: #{counts['not_ran']}" if counts["not_ran"] > 0
        @io.puts(summary)
      end
  end
end
