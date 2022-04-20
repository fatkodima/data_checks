# frozen_string_literal: true

require_relative "test_helper"

class ConfigTest < MiniTest::Test
  def test_adding_duplicate_check
    config.ensure_no :check_name

    assert_raises_with_message(ArgumentError, "Duplicate check: 'check_name'") do
      config.ensure_no :check_name
    end
  end

  def test_adding_duplicate_notifier
    config.notifier :logger

    assert_raises_with_message(ArgumentError, "Duplicate notifier: 'logger'") do
      config.notifier :logger
    end
  end

  def test_multiple_notifiers
    config.ensure_no :check_name do
      1
    end

    io = StringIO.new
    config.notifier :logger, logdev: io

    config.notifier :email, from: "no-reply@example.com", to: "user@example.com"

    run_check(:check_name)

    assert_match(/Check Failing/i, io.string)

    email = ActionMailer::Base.deliveries.last
    assert_match(/Check Failing/i, email.subject)
  end

  def test_per_check_notifiers
    config.ensure_no :check_name, notify: :logger do
      1
    end

    io = StringIO.new
    config.notifier :logger, logdev: io

    config.notifier :email, from: "no-reply@example.com", to: "user@example.com"

    run_check(:check_name)

    assert_empty ActionMailer::Base.deliveries
    assert_match(/Check Failing/i, io.string)
  end

  def test_named_notifiers
    config.ensure_no :check_name, notify: "admin_email" do
      1
    end

    config.notifier "admin_email", type: :email, from: "no-reply@example.com", to: "user@example.com"

    run_check(:check_name)

    email = ActionMailer::Base.deliveries.last
    assert_match(/Check Failing/i, email.subject)
  end

  def test_unknown_notifiers
    config.ensure_no :check_name, notify: :email do
      1
    end

    assert_raises_with_message(RuntimeError, "Unknown notifier: 'email'") do
      run_check(:check_name)
    end
  end

  private
    def config
      DataChecks.config
    end
end
