# frozen_string_literal: true

module DataChecks
  module Notifiers
    class LoggerDefaultFormatter
      def initialize(check_result)
        @check_run = check_result.check.check_run
      end

      def message
        "[data_checks] Check #{@check_run.status.titleize}: #{@check_run.name}"
      end
    end
  end
end
