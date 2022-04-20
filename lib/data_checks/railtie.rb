# frozen_string_literal: true

module DataChecks
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/data_checks.rake"
    end
  end
end
