# frozen_string_literal: true

require_relative "test_helper"

class EnsureEqualTest < Minitest::Test
  def teardown
    super
    User.delete_all
  end

  def test_numeric_result
    config.ensure_equal :fraud_users_count, to: 0 do
      User.where(fraud: true).count
    end

    _user = User.create!(fraud: false)

    result = run_check(:fraud_users_count)
    assert result.passing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_failing_numeric_result
    config.ensure_equal :fraud_users_count, to: 0 do
      User.where(fraud: true).count
    end

    _user = User.create!(fraud: true)

    result = run_check(:fraud_users_count)
    assert result.failing?
    assert_equal 1, result.count
    assert_nil result.entries
  end

  def test_relation_result
    config.ensure_equal :fraud_users, to: 0 do
      User.where(fraud: true)
    end

    _user = User.create!(fraud: false)

    result = run_check(:fraud_users)
    assert result.passing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_failing_relation_result
    config.ensure_equal :fraud_users, to: 0 do
      User.where(fraud: true)
    end

    user = User.create!(fraud: true)

    result = run_check(:fraud_users)
    assert result.failing?
    assert_equal 1, result.count
    assert_equal [user], result.entries
  end

  def test_enumerable_result
    config.ensure_equal :fraud_users, to: 0 do
      User.where(fraud: true).to_a
    end

    _user = User.create!(fraud: false)

    result = run_check(:fraud_users)
    assert result.passing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_failing_enumerable_result
    config.ensure_equal :fraud_users, to: 0 do
      User.where(fraud: true).to_a
    end

    user = User.create!(fraud: true)

    result = run_check(:fraud_users)
    assert result.failing?
    assert_equal 1, result.count
    assert_equal [user], result.entries
  end

  def test_unknown_result
    config.ensure_equal :fraud_users, to: 0 do
      :unknown_result
    end

    assert_raises_with_message(ArgumentError, "Unsupported result: 'Symbol' for 'ensure_equal'") do
      run_check(:fraud_users)
    end
  end

  private
    def config
      DataChecks.config
    end
end
