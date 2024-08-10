# frozen_string_literal: true

module DataChecks
  class EnsureNo < Check
    private
      def handle_result(result)
        passing = true
        count = 0

        case result
        when Numeric
          if result != 0
            passing = false
            count = result
          end
        when Enumerable
          unless result.to_a.empty? # loads records for ActiveRecord::Relation
            passing = false
            count = result.size
            entries = result
          end
        when true
          passing = false
          count = 1
        when false
          # ok
        else
          raise ArgumentError, "Unsupported result: '#{result.class.name}' for 'ensure_no'"
        end

        CheckResult.new(check: self, passing: passing, count: count, entries: entries)
      end
  end
end
