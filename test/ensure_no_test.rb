# frozen_string_literal: true

require_relative "test_helper"

class EnsureNoTest < Minitest::Test
  def teardown
    super
    User.delete_all
  end

  def test_numeric_result
    config.ensure_no :users_without_emails do
      User.where(email: nil).count
    end

    result = run_check(:users_without_emails)
    assert result.passing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_failing_numeric_result
    config.ensure_no :users_without_emails do
      User.where(email: nil).count
    end

    _user = User.create!(email: nil)

    result = run_check(:users_without_emails)
    assert result.failing?
    assert_equal 1, result.count
    assert_nil result.entries
  end

  def test_relation_result
    config.ensure_no :users_without_emails do
      User.where(email: nil)
    end

    result = run_check(:users_without_emails)
    assert result.passing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_failing_relation_result
    config.ensure_no :users_without_emails do
      User.where(email: nil)
    end

    user1 = User.create!(email: nil)
    _user2 = User.create!(email: "user@example.com")

    result = run_check(:users_without_emails)
    assert result.failing?
    assert_equal 1, result.count
    assert_equal [user1.id], result.entries.map(&:id)
  end

  def test_enumerable_result
    config.ensure_no :users_without_emails do
      User.where(email: nil).to_a
    end

    result = run_check(:users_without_emails)
    assert result.passing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_failing_enumerable_result
    config.ensure_no :users_without_emails do
      User.where(email: nil).to_a
    end

    user1 = User.create!(email: nil)
    _user2 = User.create!(email: "user@example.com")

    result = run_check(:users_without_emails)
    assert result.failing?
    assert_equal 1, result.count
    assert_equal [user1.id], result.entries.map(&:id)
  end

  def test_boolean_result
    config.ensure_no :users_without_emails do
      User.where(email: nil).exists?
    end

    result = run_check(:users_without_emails)
    assert result.passing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_failing_boolean_result
    config.ensure_no :users_without_emails do
      User.where(email: nil).exists?
    end

    _user = User.create!(email: nil)

    result = run_check(:users_without_emails)
    assert result.failing?
    assert_equal 1, result.count
    assert_nil result.entries
  end

  def test_unknown_result
    config.ensure_no :users_without_emails do
      :unknown_result
    end

    assert_raises_with_message(ArgumentError, "Unsupported result: 'Symbol' for 'ensure_no'") do
      run_check(:users_without_emails)
    end
  end

  private
    def config
      DataChecks.config
    end
end
