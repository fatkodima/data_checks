# frozen_string_literal: true

require "test_helper"

class LoggerNotifierTest < Minitest::Test
  def setup
    config.notifier :logger
  end

  def teardown
    super
    User.delete_all
  end

  def test_logger
    config.ensure_no :users_without_emails do
      User.where(email: nil).count
    end

    _user = User.create!(email: nil)

    out, = capture_io do
      run_checks
    end
    assert_equal "[data_checks] Check Failing: users_without_emails\n", out
  end

  private
    def config
      DataChecks.config
    end
end
