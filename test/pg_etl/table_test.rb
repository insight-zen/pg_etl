# frozen_string_literal: true

require "test_helper"

module PgEtl
  class TableTest < Minitest::Test
    def pages_def
      [{ table_name: "insight_core_pages",
        column_name: "account_id",
        data_type: "integer",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: "32" },
       { table_name: "insight_core_pages",
        column_name: "active",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: "1",
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "ancestors",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "body",
        data_type: "text",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "code",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "created_at",
        data_type: "timestamp without time zone",
        is_nullable: "NO",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: "6",
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "description",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "group",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "id",
        data_type: "bigint",
        is_nullable: "NO",
        column_default: "nextval('insight_core_pages_id_seq'::regclass)",
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: "64" },
       { table_name: "insight_core_pages",
        column_name: "keywords",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "page_type",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: "1",
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "parent_code",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "parent_id",
        data_type: "integer",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: "32" },
       { table_name: "insight_core_pages",
        column_name: "partial",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "prefs",
        data_type: "jsonb",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "resource_id",
        data_type: "integer",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: "32" },
       { table_name: "insight_core_pages",
        column_name: "resource_type",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "title",
        data_type: "character varying",
        is_nullable: "YES",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: nil,
        numeric_precision: nil },
       { table_name: "insight_core_pages",
        column_name: "updated_at",
        data_type: "timestamp without time zone",
        is_nullable: "NO",
        column_default: nil,
        character_maximum_length: nil,
        datetime_precision: "6",
        numeric_precision: nil }]
    end

    # Modify pages_def based on input
    def mod_page_def(**opts)
      rv = pages_def
      removals = [opts[:removals]].flatten.compact
      edits = opts[:edits].compact
      rv = rv.filter_map { |c| removals.include?(c[:column_name]) ? nil : c }
      rv = rv.map { |c|
        if edits.keys.include?(c[:column_name])
          c.merge(edits[c[:column_name]])
        else
          c
        end
      }
      rv
    end

    def pages_def2
      rv = pages_def
      removals = ["ancestors", "parent_id"]
      edits = {
        "account_id" => { data_type: "bigint" },
        "active" => { character_maximum_length: "99" },
        "group" => { data_type: "integer", is_nullable: "NO" },
      }
      rv = rv.filter_map { |c| removals.include?(c[:column_name]) ? nil : c }
      rv = rv.map { |c|
        if edits.keys.include?(c[:column_name])
          c.merge(edits[c[:column_name]])
        else
          c
        end
      }
      rv
    end

    # test "build pages" do
    #   t = Table.new(name: "insight_core_pages", col_array: pages_def)
    #   assert_equal "insight_core_pages", t.name
    #   assert_equal 19, t.num_columns
    #   c = t.column(:prefs)
    #   assert_equal "PgEtl::Column", c.class.to_s, t.column_names
    #   col_spec_hash = { prefs: { type: :jsonb, limit: 0 } }
    #   assert_equal col_spec_hash, c.spec_hash
    # end

    test "spec_hash for a table " do
      t = Table.new(name: "insight_core_pages", col_array: pages_def)
      spec_hash = t.spec_hash
      assert_equal true, HashZen::Utils.include?(input: spec_hash, keys: t.columns.map { |c| c.name.to_sym }), spec_hash.keys
    end

    test "account_id changed in data type" do
      col_name = :account_id
      t0 = Table.new(name: "insight_core_pages", col_array: pages_def)
      pages2 = mod_page_def(edits: { col_name.to_s => { data_type: "bigint" } })
      t1 = Table.new(name: "insight_core_pages", col_array: pages2)

      # account_id datatype is changed. Check longhand and with diff and results
      c0, c1 = t0.column(col_name), t1.column(col_name)
      diff = c0.diff(c1)
      assert_equal [col_name], diff.delta_keys
      assert_equal({ s: :delta, v: [{ type: :integer }, { type: :bigint }] }, diff.result[:map][col_name])
    end

    test "active changed in length" do
      col_name = :active
      t0 = Table.new(name: "insight_core_pages", col_array: pages_def)
      pages2 = mod_page_def(edits: { col_name.to_s => { character_maximum_length: "99" } })
      t1 = Table.new(name: "insight_core_pages", col_array: pages2)

      # account_id datatype is changed. Check longhand and with diff and results
      c0, c1 = t0.column(col_name), t1.column(col_name)
      diff = c0.diff(c1)
      assert_equal [col_name], diff.delta_keys
      assert_equal({ s: :delta, v: [{ type: :string, limit: 1 }, { type: :string, limit: 99 }] }, diff.result[:map][col_name])
    end

    test "build pages2" do
      t0 = Table.new(name: "insight_core_pages", col_array: pages_def)
      # t2 does not have keys that are in removals, and edits are applied to the schema of t2
      removals = ["ancestors", "parent_id"]
      edits = {
        "account_id" => { data_type: "bigint" },
        "active" => { character_maximum_length: "99" },
        "group" => { data_type: "integer", is_nullable: "NO" },
      }

      pages2 = mod_page_def(edits: edits, removals: removals)
      t2 = Table.new(name: "insight_core_pages", col_array: pages2)
      diff = t0.diff(t2: t2)

      assert_equal [], diff.missing_keys
      # Extra columns
      assert_equal [:ancestors, :parent_id], diff.extra_keys
      # Columns that have changed
      assert_equal [:account_id, :active, :group], diff.delta_keys
      assert_equal({ s: :delta, v: [{ type: :string, limit: 1 }, { type: :string, limit: 99 }] }, diff.result[:map][:active])
      assert_equal({ s: :delta, v: [{ type: :string }, { type: :integer }] }, diff.result[:map][:group])
      assert_equal({ s: :delta, v: [{ type: :integer }, { type: :bigint }] }, diff.result[:map][:account_id])
    end
  end
end
