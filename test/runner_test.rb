# frozen_string_literal: true

require "test_helper"

class RunnerTest < MiniTest::Test
  def test_run_checks
    io = StringIO.new
    config.notifier :logger, logdev: io

    config.ensure_no :hourly_check, tag: "hourly" do
      1
    end
    config.ensure_no :daily_check, tag: "daily" do
      1
    end

    run_checks

    output = io.string
    assert_match(/hourly_check/i, output)
    assert_match(/daily_check/i, output)
  end

  def test_run_tagged_checks
    io = StringIO.new
    config.notifier :logger, logdev: io

    config.ensure_no :hourly_check, tag: "hourly" do
      1
    end
    config.ensure_no :daily_check, tag: "daily" do
      1
    end

    run_checks(tag: "hourly")

    output = io.string
    assert_match(/hourly_check/i, output)
    refute_match(/daily_check/i, output)
  end

  def test_run_check
    io = StringIO.new
    config.notifier :logger, logdev: io

    config.ensure_no :check_name do
      1
    end

    run_check(:check_name)

    output = io.string
    assert_match(/check_name/i, output)
  end

  def test_run_non_existent_check
    assert_raises_with_message(RuntimeError, "Check non_existent not found") do
      run_check(:non_existent)
    end
  end

  def test_run_passing_check_saves_result
    config.ensure_no :check_name do
      0
    end

    run_check(:check_name)

    check_run = DataChecks::CheckRun.find_by!(name: "check_name")
    assert_equal DataChecks::CheckRun.statuses[:passing], check_run.status
    assert_nil check_run.error_class
    assert_nil check_run.error_message
    assert_nil check_run.backtrace
    refute_nil check_run.last_run_at
  end

  def test_run_failing_check_saves_result
    config.ensure_no :check_name do
      1
    end

    run_check(:check_name)

    check_run = DataChecks::CheckRun.find_by!(name: "check_name")
    assert_equal DataChecks::CheckRun.statuses[:failing], check_run.status
    assert_nil check_run.error_class
    assert_nil check_run.error_message
    assert_nil check_run.backtrace
    refute_nil check_run.last_run_at
  end

  def test_run_error_check_saves_result
    config.ensure_no :check_name do
      raise "boom"
    end

    run_check(:check_name)

    check_run = DataChecks::CheckRun.find_by!(name: "check_name")
    assert_equal DataChecks::CheckRun.statuses[:error], check_run.status
    assert_equal "RuntimeError", check_run.error_class
    assert_equal "boom", check_run.error_message
    refute_empty check_run.backtrace
    refute_nil check_run.last_run_at
  end

  def test_run_error_check_calls_error_handler
    previous_error_handler = config.error_handler

    called = false
    config.error_handler = ->(error, context) do
      called = true
      assert_equal RuntimeError, error.class
      assert_equal "boom", error.message
      assert_equal "check_name", context[:check_name]
      refute_nil context[:run_at]
    end

    config.ensure_no :check_name do
      raise "boom"
    end

    run_check(:check_name)
    assert called
  ensure
    config.error_handler = previous_error_handler
  end

  def test_run_check_does_not_notify_when_passing
    io = StringIO.new
    config.notifier :logger, logdev: io

    config.ensure_no :check_name do
      0
    end

    run_check(:check_name)
    assert_empty io.string
  end

  def test_run_check_notifies_when_not_passing
    io = StringIO.new
    config.notifier :logger, logdev: io

    config.ensure_no :check_name do
      1
    end

    run_check(:check_name)
    assert_match(/check_name/i, io.string)
  end

  def test_run_check_notifies_when_status_changed
    io = StringIO.new
    config.notifier :logger, logdev: io

    calls = 0

    config.ensure_no :check_name do
      if calls == 0
        calls += 1
        1
      else
        0
      end
    end

    run_check(:check_name) # failing
    assert_equal "[data_checks] Check Failing: check_name\n", io.string

    io.truncate(0)
    io.rewind

    run_check(:check_name) # passing
    assert_equal "[data_checks] Check Passing: check_name\n", io.string
  end

  private
    def config
      DataChecks.config
    end
end
