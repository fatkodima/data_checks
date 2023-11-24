# frozen_string_literal: true

require "test_helper"

require "generators/data_checks/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests DataChecks::InstallGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_creates_migration_file
    run_generator

    assert_migration("db/migrate/install_data_checks.rb") do |content|
      assert_includes content, "create_table :data_checks_runs"
    end
  end

  def test_creates_initializer_file
    run_generator

    assert_file("config/initializers/data_checks.rb") do |content|
      assert_includes content, "DataChecks.configure do"
      %w[
        :ensure_no
        :ensure_any
        :ensure_more
        :ensure_less
        :ensure_equal
      ].each do |dsl_method_name|
        assert_includes content, dsl_method_name
      end
    end
  end
end
