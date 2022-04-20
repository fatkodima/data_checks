# frozen_string_literal: true

require "test_helper"

class SlackNotifierTest < MiniTest::Test
  def setup
    config.notifier :slack, webhook_url: "https://hooks.slack.com/services/abc"
  end

  def teardown
    super
    User.delete_all
  end

  def test_slack
    config.ensure_no :users_without_emails do
      User.where(email: nil).count
    end

    _user = User.create!(email: nil)

    payload = {
      attachments: [
        {
          title: "Check Failing: users_without_emails",
          text: "Checker found 1 element(s).",
          color: "danger",
        },
      ],
    }

    stub_post = stub_request(:post, "https://hooks.slack.com/services/abc")
      .with(body: payload.to_json)
      .to_return(body: "ok")

    run_checks

    assert_requested stub_post
  end

  def test_slack_with_error
    config.ensure_no :users_without_emails do
      raise "Query timed out"
    end

    payload = {
      attachments: [
        {
          title: "Check Error: users_without_emails",
          text: "Query timed out",
          color: "danger",
        },
      ],
    }

    stub_post = stub_request(:post, "https://hooks.slack.com/services/abc")
      .with(body: payload.to_json)
      .to_return(body: "ok")

    run_checks

    assert_requested stub_post
  end

  def test_slack_with_entries
    config.ensure_no :users_without_emails do
      User.where(email: nil)
    end

    user = User.create!(email: nil)

    payload = {
      attachments: [
        {
          title: "Check Failing: users_without_emails",
          text: "Checker found 1 element(s).\n- #{user.id}",
          color: "danger",
        },
      ],
    }

    stub_post = stub_request(:post, "https://hooks.slack.com/services/abc")
      .with(body: payload.to_json)
      .to_return(body: "ok")

    run_checks

    assert_requested stub_post
  end

  def test_slack_returns_error
    previous_error_handler = DataChecks.config.error_handler
    DataChecks.config.error_handler = nil

    config.ensure_no :users_without_emails do
      User.where(email: nil).count
    end

    _user = User.create!(email: nil)

    stub_request(:post, "https://hooks.slack.com/services/abc")
      .to_return(status: 500, body: "Error")

    assert_raises_with_message(RuntimeError, 'Failed to notify slack: "Error"') do
      run_checks
    end
  ensure
    DataChecks.config.error_handler = previous_error_handler
  end

  private
    def config
      DataChecks.config
    end
end
