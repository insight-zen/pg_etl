# frozen_string_literal: true

# require_relative "table.rb"

module PgEtl
  class Column

    # How postgresql columns map to rails schema symbols
    RailsColumnTypeMap = {
        "character varying" => :string,
        "timestamp without time zone" => :datetime,
        "bigint" => :bigint,
        "jsonb" => :jsonb,
        "integer" => :integer,
      }

    # Name of column and details as a spec hash
    def initialize(spec:)
      @spec = spec
    end

    def debug
      @spec.inspect
    end

    # %i{type numeric_precision column_default null limit}.each do |c|
    #   define_method "#{c}" do
    #     @opts[c]
    #   end
    # end

    %i{ table_name column_name data_type is_nullable column_default character_maximum_length datetime_precision numeric_precision}.each do |c|
      define_method "#{c}" do
        @spec[c]
      end
    end

    def name
      @spec[:column_name]
    end

    def rails_spec
      rv = {}
      @spec.each_pair { |key, value|
        if key == :data_type
          rv[:type] = RailsColumnTypeMap[value]
        elsif key == :is_nullable
          rv[:null] = false if value == "NO"
        elsif key == :datetime_precision
          rv[:limit] = value.to_i
        elsif key == :character_maximum_length
          rv[:limit] = value.to_i
        else
          rv[key] = value
        end
      }
      rv
    end

    def to_s(**opts)

    end

  end
end