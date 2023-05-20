# frozen_string_literal: true

module DataChecks
  class EnsureEqual < Check
    private
      def handle_result(result)
        expected = options.fetch(:to)
        passing = true
        count = 0

        case result
        when Numeric
          if result != expected
            passing = false
            count = result
          end
        # In ActiveRecord <= 4.2 ActiveRecord::Relation is not an Enumerable!
        when Enumerable, ActiveRecord::Relation
          count = result.size
          if count != expected
            passing = false
            entries = result
          end
        else
          raise ArgumentError, "Unsupported result: '#{result.class.name}' for 'ensure_equal'"
        end

        CheckResult.new(check: self, passing: passing, count: count, entries: entries)
      end
  end
end
