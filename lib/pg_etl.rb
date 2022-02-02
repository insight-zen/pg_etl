# frozen_string_literal: true

require "pg"
require "hash_zen"
require "pg_etl/version"
require "pg_etl/connection"
require "pg_etl/admin"
# load "pg_etl/admin"

module PgEtl
  class Error < StandardError; end
  # Your code goes here...
end

module PG
  def self.databases
    PgEtl::Admin.databases
  end

  def self.[](name)
    PgEtl::Connection.new(db_name: name)
  end

  # Build a new database from the given dump file
  def self.build(db_name:, dump_file:, **opts)
    raise("Dump file: #{dump_file} does not exist") unless File.exists?(dump_file)

    if PgEtl::Admin.database_exists?(db_name)
      if opts[:overwrite] == :yes
        PgEtl::Admin.drop_database(db_name: db_name)
      else
        raise("Database #{db_name} already exists. To overwrite, remove overwrite: :yes or provide a different database")
      end
    end
    PgEtl::Admin.create_database(db_name: db_name)
    PgEtl::Admin.load(file: dump_file, db_name: db_name)

  end
end