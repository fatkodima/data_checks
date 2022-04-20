# frozen_string_literal: true

module DataChecks
  class Config
    attr_reader :checks, :notifier_options
    attr_accessor :error_handler, :backtrace_cleaner

    def initialize
      @checks = []
      @notifier_options = {}
    end

    def ensure_no(name, **options, &block)
      add_check(EnsureNo, name, options, block)
    end

    def ensure_any(name, **options, &block)
      add_check(EnsureMore, name, options.merge(than: 0), block)
    end

    def ensure_more(name, **options, &block)
      add_check(EnsureMore, name, options, block)
    end

    def ensure_less(name, **options, &block)
      add_check(EnsureLess, name, options, block)
    end

    def notifier(name, **options)
      name = name.to_s

      if notifier_options.key?(name)
        raise ArgumentError, "Duplicate notifier: '#{name}'"
      else
        options[:type] ||= name
        notifier_options[name] = options
      end
    end

    private
      def add_check(klass, name, options, block)
        name = name.to_s

        if checks.any? { |check| check.name == name }
          raise ArgumentError, "Duplicate check: '#{name}'"
        else
          checks << klass.new(name, options, block)
        end
      end
  end
end
