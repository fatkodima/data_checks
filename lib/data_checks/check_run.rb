# frozen_string_literal: true

module DataChecks
  class CheckRun < ActiveRecord::Base
    self.table_name = :data_checks_runs

    STATUSES = [:passing, :failing, :error]
    enum :status, STATUSES.index_with(&:to_s)

    serialize :backtrace

    validates :name, :status, :last_run_at, presence: true
  end
end
