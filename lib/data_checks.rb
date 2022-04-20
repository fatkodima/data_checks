# frozen_string_literal: true

require "data_checks/check_run"
require "data_checks/check_result"
require "data_checks/check"
require "data_checks/ensure_less"
require "data_checks/ensure_more"
require "data_checks/ensure_no"
require "data_checks/notifiers"
require "data_checks/config"
require "data_checks/runner"
require "data_checks/status_printer"
require "data_checks/version"

require "data_checks/railtie" if defined?(Rails)

module DataChecks
  class << self
    def config
      @config ||= Config.new
    end

    def configure(&block)
      config.instance_exec(&block)
    end
  end
end
