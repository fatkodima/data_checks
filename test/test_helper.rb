# frozen_string_literal: true

require "active_record"
require "action_mailer"

require "data_checks"

require "minitest/autorun"
require "webmock/minitest"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

if ENV["VERBOSE"]
  ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)
else
  ActiveRecord::Base.logger = ActiveSupport::Logger.new("debug.log", 1, 100 * 1024 * 1024) # 100 mb
  ActiveRecord::Migration.verbose = false
end

ActiveRecord::Schema.define do
  create_table :data_checks_runs, force: true do |t|
    t.string :name, null: false
    t.string :status, null: false
    t.datetime :last_run_at, null: false

    t.string :error_class
    t.string :error_message
    t.text :backtrace

    t.timestamps

    t.index :name, unique: true
  end

  create_table :users, force: true do |t|
    t.string :email
    t.boolean :fraud
    t.timestamps
  end
end

class User < ActiveRecord::Base
end

class Minitest::Test # rubocop:disable Style/ClassAndModuleChildren
  def teardown
    DataChecks.config.checks.clear
    DataChecks.config.notifier_options.clear
    DataChecks::CheckRun.delete_all
    ActionMailer::Base.deliveries.clear
    WebMock.reset!
  end

  private
    def assert_raises_with_message(exception_class, message, &block)
      error = assert_raises(exception_class, &block)
      assert_match message, error.message
    end

    def run_checks(tag: nil)
      DataChecks::Runner.new.run_checks(tag: tag)
    end

    def run_check(name)
      DataChecks::Runner.new.run_check(name)
    end
end

ActionMailer::Base.delivery_method = :test
WebMock.disable_net_connect!

DataChecks.configure do
  # Swallow everything to be able to test erroring checks.
  self.error_handler = ->(error, context) {}
end
