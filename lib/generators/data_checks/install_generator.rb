# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record/migration"

module DataChecks
  class InstallGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    def create_migration_file
      migration_template("migration.rb", File.join(migrations_dir, "install_data_checks.rb"))
    end

    def copy_initializer_file
      template("initializer.rb", "config/initializers/data_checks.rb")
    end

    private
      def start_after
        self.class.next_migration_number(migrations_dir)
      end

      def migrations_dir
        ar_version >= 5.1 ? db_migrate_path : "db/migrate"
      end

      def ar_version
        ActiveRecord.version.to_s.to_f
      end
  end
end
