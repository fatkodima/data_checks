# frozen_string_literal: true

module DataChecks
  class Check
    attr_reader :name, :options, :tag, :block

    def initialize(name, options, block)
      @name = name.to_s
      @options = options
      @tag = options[:tag]&.to_s
      @block = block
    end

    def run
      result = block.call
    rescue Exception => e # rubocop:disable Lint/RescueException
      error_result(e)
    else
      handle_result(result)
    end

    def check_run
      @check_run ||= CheckRun.find_by(name: name)
    end

    def notifiers
      configured_notifiers = DataChecks.config.notifier_options
      notifiers = Array(options[:notify] || configured_notifiers.keys).map(&:to_s)

      notifiers.map do |notifier|
        raise "Unknown notifier: '#{notifier}'" unless configured_notifiers.key?(notifier)

        type = configured_notifiers[notifier][:type]
        klass = Notifiers.lookup(type)
        klass.new(configured_notifiers[notifier])
      end
    end

    private
      def handle_result(_result)
        raise NotImplementedError, "#{self.class.name} must implement a 'handle_result' method"
      end

      def error_result(error)
        CheckResult.new(check: self, error: error)
      end
  end
end
