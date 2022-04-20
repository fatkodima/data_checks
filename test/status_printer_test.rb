# frozen_string_literal: true

require "test_helper"

class StatusPrinterTest < MiniTest::Test
  def setup
    DataChecks.configure do
      ensure_no :failing_check do
        1
      end
      ensure_no :passing_check do
        0
      end
      ensure_no :error_check do
        raise "boom"
      end
    end
  end

  def test_prints_individual_task_statuses
    run_checks

    output = print_statuses

    assert_match(/Check failing_check \(at .*\) - Failing/i, output)
    assert_match(/Check passing_check \(at .*\) - Passing/i, output)
    assert_match(/Check error_check \(at .*\) - Error/i, output)
  end

  def test_prints_summary
    run_check(:failing_check)
    run_check(:passing_check)

    output = print_statuses

    assert_match(/Error: 0, Failing: 1, Passing: 1, Not Ran: 1/i, output)
  end

  def test_skips_not_ran_checks_in_summary_if_none
    run_checks

    output = print_statuses

    assert_match(/Error: 1, Failing: 1, Passing: 1/i, output)
    refute_match(/Not Ran: 0/i, output)
  end

  private
    def print_statuses
      io = StringIO.new
      printer = DataChecks::StatusPrinter.new(io)
      printer.print
      io.string
    end
end
