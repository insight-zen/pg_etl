# frozen_string_literal: true

require_relative "lib/pg_etl/version"

Gem::Specification.new do |spec|
  spec.name = "pg_etl"
  spec.version = PgEtl::VERSION
  spec.authors = ["Insight Magnet Team"]
  spec.email = ["support@insight-magnet.com"]

  spec.summary = "Extract, Transform, Load functions for postgreq databases"
  spec.description = "Low level database operations suitable for a DBA. Catalog queries, modify tables structures. Scrub and insert data."
  spec.homepage = "https://github.com/insight-zen/pg_etl"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  # https://thoughtbot.com/blog/rubys-pessimistic-operator
  # "~> 4.0.0" is the same as ">= 4.0.0", "< 4.1.0"
  # "~> 1.1"   is the same as ">= 1.1",   "< 2.0"

  spec.add_dependency "pg", "~> 1.1"

  # This gem depends on hash_zen. For local development this is listed in Gemfile with a local override
  # This is because add_dependency does not accept git: as an argument

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-performance"

end
