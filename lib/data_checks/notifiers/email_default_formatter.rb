# frozen_string_literal: true

module DataChecks
  module Notifiers
    class EmailDefaultFormatter
      def initialize(check_result)
        @check_run = check_result.check.check_run
        @check_result = check_result
      end

      def subject
        "Check #{@check_run.status.titleize}: #{@check_run.name}"
      end

      def body
        error = @check_run.error_message
        count = @check_result.count
        entries = @check_result.entries&.map { |entry| format_entry(entry) }

        if error
          "<p>#{error}</p>"
        else
          body = "<p>Checker found #{count} element(s).</p>"
          if entries
            if count > 10
              body += "<p>Showing 10 of #{count} entries</p>"
            end

            body += format("<ul>%s</ul>", entries.map { |entry| "<li>#{entry}</li>" }.join)
          end
          body
        end
      end

      private
        def format_entry(entry)
          entry.respond_to?(:id) ? entry.id : entry.to_s
        end
    end
  end
end
