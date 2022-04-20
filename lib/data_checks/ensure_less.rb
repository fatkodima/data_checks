# frozen_string_literal: true

module DataChecks
  class EnsureLess < Check
    private
      def handle_result(result)
        expected = options.fetch(:than)
        passing = true

        case result
        when Numeric
          count = result
          if result >= expected
            passing = false
          end
        when Enumerable
          count = result.count
          if count >= expected
            passing = false
          end
        else
          raise ArgumentError, "Unsupported result: '#{result.class.name}' for 'ensure_less'"
        end

        CheckResult.new(check: self, passing: passing, count: count)
      end
  end
end
