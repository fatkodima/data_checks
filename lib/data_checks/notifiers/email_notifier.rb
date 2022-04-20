# frozen_string_literal: true

module DataChecks
  module Notifiers
    class EmailNotifier < Notifier
      def initialize(options)
        super
        @formatter_class = options.delete(:formatter_class) || EmailDefaultFormatter
      end

      def notify(check_result)
        formatter = @formatter_class.new(check_result)

        body = formatter.body
        email_options = { subject: formatter.subject }.merge(options)
        Mailer.notify(body, email_options).deliver_now
      end

      class Mailer < ::ActionMailer::Base
        layout false

        def notify(body, options)
          mail(options) do |format|
            format.html { render html: body.html_safe }
          end
        end
      end
    end
  end
end
