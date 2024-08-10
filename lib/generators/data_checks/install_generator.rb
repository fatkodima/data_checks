# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record/migration"

module DataChecks
  class InstallGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    def create_migration_file
      migration_template("migration.rb", File.join(db_migrate_path, "install_data_checks.rb"))
    end

    def copy_initializer_file
      template("initializer.rb", "config/initializers/data_checks.rb")
    end

    private
      def start_after
        self.class.next_migration_number(db_migrate_path)
      end

      def ar_version
        ActiveRecord.version.to_s.to_f
      end
  end
end
