# frozen_string_literal: true

require "test_helper"

module PgEtl
  class ConnectionTest < Minitest::Test
    test "connection to base database" do
      base = Connection.new(db_name: "postgres")
      assert base.is_a?(PgEtl::Connection), base.class.name
      base.close
    end

    [:plain, :custom].each do |format|
      test "output file extension for format #{format}" do
        base = Connection.new(db_name: "postgres")
        assert_equal base.format_ext_map[format], File.extname(base.output_file_name(format: format))
        base.close
      end
    end

    test "dump a database in plain format" do
      base = Connection.new(db_name: "site2020")
      ts = "xx_yy_zz"
      out_file = base.output_file_name(format: :plain, time_stamp: ts)
      File.delete(out_file) if File.exist?(out_file)
      assert_equal false, File.exist?(out_file)
      base.dump(time_stamp: ts, quiet: true)
      assert_equal true, File.exist?(out_file)
      # File.delete(out_file) if File.exist?(out_file)
    end

    test "Create a brand new database from a dump" do
      db_name = "tst_456"
      Admin.drop_database(db_name: db_name, only_if_exists: true, quiet: true)
      assert_equal false, Admin.database_exists?(db_name)

      assert_equal true, Admin.create_database(db_name: db_name, quiet: true)

      base = Connection.new(db_name: db_name)
      assert_equal({}, base.q_tables(format: :hash))

      file = File.expand_path(File.join(__FILE__, "../../files/plain_3tab.txt"))
      assert_equal true, File.exist?(file), "Checking if file: #{file} exists."
      rv = base.load(file: file, quiet: true)
      assert_equal true, rv
      result = { accounts: { num_columns: 8, rows: 1 }, comments: { num_columns: 9, rows: 0 }, pages: { num_columns: 19, rows: 9 } }
      assert_equal result, base.q_tables(format: :hash)
    end
  end
end
