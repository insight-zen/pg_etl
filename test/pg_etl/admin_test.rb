# frozen_string_literal: true

require "test_helper"

module PgEtl
  class AdminTest < Minitest::Test
    test "databases" do
      databases = Admin.databases
      assert_equal true, databases.is_a?(Array), databases.inspect
      assert_equal true, Admin.database_exists?("postgres")
    end

    test "create new database and drop it" do
      db_name = "XYZ_XYZ"
      Admin.drop_database(db_name: db_name, only_if_exists: true)
      # if Admin.database_exists?(db_name)
      #   raise("Database #{db_name} exists. Test requires that this database is not present. Either drop it or use a different database name ")
      # end

      # assert_equal false, Admin.database_exists?(db_name)
      Admin.create_database(db_name: db_name, quiet: true)
      assert_equal true, Admin.database_exists?(db_name)

      Admin.drop_database(db_name: db_name, quiet: true)
      assert_equal false, Admin.database_exists?(db_name)
    end
  end
end
