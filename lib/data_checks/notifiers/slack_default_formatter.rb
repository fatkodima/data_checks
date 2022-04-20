# frozen_string_literal: true

module DataChecks
  module Notifiers
    class SlackDefaultFormatter
      def initialize(check_result)
        @check_run = check_result.check.check_run
        @check_result = check_result
      end

      def title
        escape("Check #{@check_run.status.titleize}: #{@check_run.name}")
      end

      def text
        error = @check_run.error_message
        count = @check_result.count
        entries = @check_result.entries&.map { |entry| format_entry(entry) }

        if error
          escape(error)
        else
          text = ["Checker found #{count} element(s)."]
          if entries
            if count > 10
              text << "Showing 10 of #{count} entries"
            end

            text += entries.first(10).map { |entry| "- #{entry}" }
          end

          escape(text.join("\n"))
        end
      end

      def color
        if @check_run.status == CheckRun.statuses[:passing]
          "good"
        else
          "danger"
        end
      end

      private
        # https://api.slack.com/docs/message-formatting#how_to_escape_characters
        def escape(str)
          str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
        end

        def format_entry(entry)
          entry.respond_to?(:id) ? entry.id : entry.to_s
        end
    end
  end
end
