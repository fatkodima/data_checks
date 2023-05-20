# frozen_string_literal: true

require "active_record"

require "data_checks/version"
require "data_checks/railtie" if defined?(Rails)

module DataChecks
  extend ActiveSupport::Autoload

  autoload :Check
  autoload :CheckResult
  autoload :CheckRun
  autoload :Config
  autoload :EnsureEqual
  autoload :EnsureLess
  autoload :EnsureMore
  autoload :EnsureNo
  autoload :Notifiers
  autoload :Runner
  autoload :StatusPrinter

  class << self
    def config
      @config ||= Config.new
    end

    def configure(&block)
      config.instance_exec(&block)
    end
  end
end
