# frozen_string_literal: true

require "active_support/logger"

module DataChecks
  module Notifiers
    class LoggerNotifier < Notifier
      def initialize(options)
        super

        logdev = options[:logdev] || $stdout
        level = options[:level] || Logger::INFO
        @logger = ActiveSupport::Logger.new(logdev, level: level)
        @formatter_class = options.delete(:formatter_class) || LoggerDefaultFormatter
      end

      def notify(check_result)
        formatter = @formatter_class.new(check_result)
        @logger.add(@logger.level, formatter.message)
      end
    end
  end
end
