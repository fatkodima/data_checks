# frozen_string_literal: true

require_relative "lib/data_checks/version"

Gem::Specification.new do |spec|
  spec.name = "data_checks"
  spec.version = DataChecks::VERSION
  spec.authors = ["fatkodima"]
  spec.email = ["fatkodima123@gmail.com"]

  spec.summary = "Regression testing for data"
  spec.homepage = "https://github.com/fatkodima/data_checks"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 7.0"
end
