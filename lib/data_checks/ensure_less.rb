# frozen_string_literal: true

module DataChecks
  class EnsureLess < Check
    private
      def handle_result(result)
        expected = options.fetch(:than)

        case result
        when Numeric
          count = result
        when Enumerable, ActiveRecord::Relation
          count = result.size
        else
          raise ArgumentError, "Unsupported result: '#{result.class.name}' for 'ensure_less'"
        end

        passing = count < expected
        CheckResult.new(check: self, passing: passing, count: count)
      end
  end
end
