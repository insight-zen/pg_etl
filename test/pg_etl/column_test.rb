# frozen_string_literal: true

require "test_helper"

module PgEtl
  class ColumnTest < Minitest::Test
    test "build" do
      # This is the output of db.q_columns(table: :insight_core_pages, format: :raw)
      c_spec = { table_name: "insight_core_pages",
        column_name: "account_id",
        data_type: "integer",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: "32" }
      rails_spec = {
        table_name: "insight_core_pages",
        column_name: "account_id",
        type: :integer,
        column_default: nil
      }

      c = Column.new(spec: c_spec)
      assert_equal "account_id", c.name, c.debug
      assert_equal "insight_core_pages", c.table_name, c.debug
      assert_equal rails_spec, c.rails_spec, c.debug
    end

    test "column diffs" do
      g0 = { table_name: "insight_core_pages",
        column_name: "group",
        data_type: "character varying",
        character_maximum_length: "100",
        is_nullable: "YES"
      }

      g1 = g0.merge(data_type: "integer", is_nullable: "NO", character_maximum_length: "55")

      group0 = Column.new(spec: g0)
      group1 = Column.new(spec: g1)
      # assert_equal group0.rails_spec, group1.rails_spec
      hd = HashZen::Diff.new(base: group0.pg_spec, target: group1.pg_spec)
      assert_equal false, hd.boolean
      assert_equal "Deltas: [character_maximum_length, data_type, is_nullable]", hd.result_one_line
      # assert_equal 1, hd.result[:groups]
      result = {
        missing: { has: false, keys: %i() },
        extra: { has: false, keys: %i() },
        common: { has: true, keys: %i(table_name column_name data_type character_maximum_length is_nullable) },
        identical: { has: true, keys: %i(table_name column_name) },
        delta: { has: true, keys: %i(data_type character_maximum_length is_nullable) }
      }
      [:missing, :extra, :common, :identical, :delta].each do |k|
        assert_equal result[k][:has], hd.send("has_#{k}?"), "Checking for #{k}_has\n#{hd.result[:groups]}"
        assert_equal result[k][:keys], hd.send("#{k}_keys"), "Checking for #{k}_keys\n#{hd.result[:groups]}"
      end
    end
  end
end
