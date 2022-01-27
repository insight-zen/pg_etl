# frozen_string_literal: true

require_relative "column.rb"

module PgEtl
  class Table
    attr_accessor :columns, :name

    # col_spec -> as returned by schema#q_columns(table: :foo, format: :raw)
    def initialize(name:, col_array: nil, db: nil, **opts)
      @name, @opts, @columns = name, opts, []
      col_array = db.q_columns(table: name, format: :raw) if db
      build_columns(col_array: col_array) unless col_array.nil?
    end

    def build_columns(col_array:, **opts)
      @columns = col_array.map do |c_spec|
        Column.new(spec: c_spec)
      end
    end

    def num_columns
      @columns.length
    end

    def column(name)
      @columns.detect { |c| c.name == name.to_s }
    end

    # List the differences with the second table
    def diff(t2:, **opts)
    end

  end
end
