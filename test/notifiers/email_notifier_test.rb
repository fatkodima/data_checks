# frozen_string_literal: true

require "test_helper"

class EmailNotifierTest < Minitest::Test
  def setup
    config.notifier :email, from: "no-reply@example.com", to: "user@example.com"
  end

  def teardown
    super
    User.delete_all
  end

  def test_email
    config.ensure_no :users_without_emails do
      User.where(email: nil).count
    end

    _user = User.create!(email: nil)

    run_checks

    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.last
    assert_equal ["no-reply@example.com"], email.from
    assert_equal ["user@example.com"], email.to
    assert_equal "Check Failing: users_without_emails", email.subject
    assert_equal "<p>Checker found 1 element(s).</p>", email.body.to_s
  end

  def test_email_with_error
    config.ensure_no :users_without_emails do
      raise "Query timed out"
    end

    run_checks

    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.last
    assert_equal "Check Error: users_without_emails", email.subject
    assert_equal "<p>Query timed out</p>", email.body.to_s
  end

  def test_email_with_entries
    config.ensure_no :users_without_emails do
      User.where(email: nil)
    end

    user = User.create!(email: nil)

    run_checks

    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.last
    assert_equal "Check Failing: users_without_emails", email.subject
    assert_equal "<p>Checker found 1 element(s).</p><ul><li>#{user.id}</li></ul>", email.body.to_s
  end

  private
    def config
      DataChecks.config
    end
end
