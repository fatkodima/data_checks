# frozen_string_literal: true

module DataChecks
  module Notifiers
    extend ActiveSupport::Autoload

    autoload :Notifier
    autoload :EmailDefaultFormatter
    autoload :EmailNotifier
    autoload :SlackDefaultFormatter
    autoload :SlackNotifier
    autoload :LoggerDefaultFormatter
    autoload :LoggerNotifier

    def self.lookup(name)
      const_get("#{name.to_s.camelize}Notifier")
    end
  end
end
