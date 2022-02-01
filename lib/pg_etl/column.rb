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

    attr_accessor :message

    # Name of column and details as a spec hash
    def initialize(spec:)
      @spec, @message = spec, {}
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

    def pg_spec
      @spec
    end

    def rails_spec
      rv = {}
      @spec.each_pair { |key, value|
        if key == :data_type
          rv[:type] = RailsColumnTypeMap[value]
        elsif key == :is_nullable
          rv[:null] = false if value == "NO"
        elsif key == :datetime_precision && value
          rv[:limit] = value.to_i
        elsif key == :character_maximum_length && value
          rv[:limit] = value.to_i
        else
          rv[key] = value
        end
      }
      %i{ character_maximum_length datetime_precision numeric_precision }.each { |k| rv.delete(k) }
      rv
    end

    # { name: rails_spec } - what you would typically see in the migration file
    def spec_hash
      { name.to_sym => rails_spec.slice(:type, :limit, :column_default, :numeric_precision) }
    end

    def diff(c2)
      HashZen::Diff.new(base: spec_hash, target: c2.spec_hash)
    end

    def equals(c2, opts = {})
      unless c2.is_a?(PgEtl::Column)
        @message.merge(base: "Not a PgEtl::Column class")
        return(false)
      end

      hd = diff(c2)
      unless hd.boolean
        @message.merge(diff: hd.result_itemized)
        return(false)
      end

      true
    end

    def to_s(**opts)
    end
  end
end
