# frozen_string_literal: true

require_relative "test_helper"

class EnsureMoreTest < MiniTest::Test
  def teardown
    super
    User.delete_all
  end

  def test_numeric_result
    config.ensure_more :new_users_within_hour, than: 0 do
      User.where("created_at >= ?", 1.hour.ago).count
    end

    _user = User.create!

    result = run_check(:new_users_within_hour)
    assert result.passing?
    assert_equal 1, result.count
    assert_nil result.entries
  end

  def test_failing_numeric_result
    config.ensure_more :new_users_within_hour, than: 0 do
      User.where("created_at >= ?", 1.hour.ago).count
    end

    result = run_check(:new_users_within_hour)
    assert result.failing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_relation_result
    config.ensure_more :new_users_within_hour, than: 0 do
      User.where("created_at >= ?", 1.hour.ago)
    end

    _user = User.create!

    result = run_check(:new_users_within_hour)
    assert result.passing?
    assert_equal 1, result.count
    assert_nil result.entries
  end

  def test_failing_relation_result
    config.ensure_more :new_users_within_hour, than: 0 do
      User.where("created_at >= ?", 1.hour.ago)
    end

    result = run_check(:new_users_within_hour)
    assert result.failing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_enumerable_result
    config.ensure_more :new_users_within_hour, than: 0 do
      User.where("created_at >= ?", 1.hour.ago).to_a
    end

    _user = User.create!

    result = run_check(:new_users_within_hour)
    assert result.passing?
    assert_equal 1, result.count
    assert_nil result.entries
  end

  def test_failing_enumerable_result
    config.ensure_more :new_users_within_hour, than: 0 do
      User.where("created_at >= ?", 1.hour.ago).to_a
    end

    result = run_check(:new_users_within_hour)
    assert result.failing?
    assert_equal 0, result.count
    assert_nil result.entries
  end

  def test_unknown_result
    config.ensure_more :new_users_within_hour, than: 0 do
      :unknown_result
    end

    assert_raises_with_message(ArgumentError, "Unsupported result: 'Symbol' for 'ensure_more'") do
      run_check(:new_users_within_hour)
    end
  end

  private
    def config
      DataChecks.config
    end
end
