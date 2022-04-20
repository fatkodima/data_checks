# frozen_string_literal: true

module DataChecks
  module Notifiers
    class Notifier
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def notify(check_result)
        raise NotImplementedError, "#{self.class.name} must implement a 'notify' method"
      end
    end
  end
end
