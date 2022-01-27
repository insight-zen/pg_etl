# frozen_string_literal: true

require "test_helper"

module PgEtl
  class ColumnTest < Minitest::Test

    test "build" do
      # This is the output of db.q_columns(table: :insight_core_pages, format: :raw)
      c_spec = {:table_name=>"insight_core_pages",
        :column_name=>"account_id",
        :data_type=>"integer",
        :is_nullable=>"YES",
        :column_default=>nil,
        :character_maximum_length=>nil,
        :datetime_precision=>nil,
        :numeric_precision=>"32"}
      rails_spec = {
        table_name: "insight_core_pages",
        column_name: "account_id",
        type: :integer,
        column_default: nil,
        limit: 0,
        numeric_precision: "32"
      }

      c = Column.new(spec: c_spec)
      assert_equal "account_id", c.name, c.debug
      assert_equal "insight_core_pages", c.table_name, c.debug
      assert_equal rails_spec, c.rails_spec, c.debug
    end

  end
end