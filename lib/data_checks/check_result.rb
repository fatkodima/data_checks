# frozen_string_literal: true

module DataChecks
  class CheckResult
    attr_reader :check, :passing, :count, :entries, :error

    def initialize(check:, passing: false, count: nil, entries: nil, error: nil)
      @check = check
      @passing = passing
      @count = count
      @entries = entries
      @error = error
    end

    def passing?
      passing
    end

    def failing?
      !passing && error.nil?
    end

    def error?
      error
    end
  end
end
