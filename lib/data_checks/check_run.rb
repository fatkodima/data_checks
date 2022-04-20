# frozen_string_literal: true

module DataChecks
  class CheckRun < ActiveRecord::Base
    self.table_name = :data_checks_runs

    STATUSES = [:passing, :failing, :error]
    enum status: STATUSES.map { |status| [status, status.to_s] }.to_h

    serialize :backtrace

    validates :name, :status, :last_run_at, presence: true
  end
end
