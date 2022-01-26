# frozen_string_literal: true

require "pg"
require_relative "pg_etl/version"
require_relative "pg_etl/connection"
require_relative "pg_etl/admin"

module PgEtl
  class Error < StandardError; end
  # Your code goes here...
end
