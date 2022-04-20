# frozen_string_literal: true

require "net/http"

module DataChecks
  module Notifiers
    class SlackNotifier < Notifier
      def initialize(options)
        super
        @formatter_class = options.delete(:formatter_class) || SlackDefaultFormatter
        @webhook_url = options.fetch(:webhook_url) { raise ArgumentError, "webhook_url must be configured" }
      end

      def notify(check_result)
        formatter = @formatter_class.new(check_result)

        payload = {
          attachments: [
            {
              title: formatter.title,
              text: formatter.text,
              color: formatter.color,
            },
          ],
        }

        response = post(payload)
        unless response.is_a?(Net::HTTPSuccess) && response.body == "ok"
          raise "Failed to notify slack: #{response.body.inspect}"
        end
      end

      private
        def post(payload)
          uri = URI.parse(@webhook_url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.open_timeout = 3
          http.read_timeout = 5
          http.post(uri.request_uri, payload.to_json)
        end
    end
  end
end
