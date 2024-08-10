# frozen_string_literal: true

module DataChecks
  class EnsureMore < Check
    private
      def handle_result(result)
        expected = options.fetch(:than)

        case result
        when Numeric
          count = result
        when Enumerable
          count = result.size
        else
          raise ArgumentError, "Unsupported result: '#{result.class.name}' for 'ensure_more'"
        end

        passing = count > expected
        CheckResult.new(check: self, passing: passing, count: count)
      end
  end
end
