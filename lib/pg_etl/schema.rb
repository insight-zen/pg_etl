# frozen_string_literal: true

module PgEtl
  module Schema
    def self.included(base)
      base.class_eval do
      end
      base.extend(ClassMethods)
    end

    #
    # - Catalog Queries
    #

    def table_sql(**opts)
      [
        "select table_name ",
        "from information_schema.tables",
        "where table_schema = 'public'",
        "order by table_name"
      ].compact.join(" ")
    end

    def column_sql(**opts)
      where_str = [
        "table_schema = 'public'",
        in_clause(field: :table_name, spec: opts[:table] || opts[:tables]),
      ].compact.join(" AND ")

      [
        "select table_name, column_name, data_type, is_nullable, column_default, character_maximum_length, datetime_precision, numeric_precision",
        "from information_schema.columns",
        "where #{where_str}",
        "order by table_name, column_name"
      ].compact.join(" ")
    end

    #
    #  -- Mod Methods --
    #

    # Run a catalog query to get a list of tables, check that all the given tables exist and then delete them
    # table can be a single table or an array
    # no_exist:
    #  skip: (default) skip that table and continue
    #  abort: exit out of the function
    #  quiet: No message is printed. Missing table is skipped.
    def drop_table(table:, **opts)
      tab_list = [table].flatten.compact
      return if tab_list.length == 0
      schema_tables = q_tables(names_only: true)
      drops, skips = [], []
      tab_list.each do |table|
        exist = schema_tables.include?(table)
        if exist
          sql = "DROP TABLE #{table}"
          execute(sql: sql)
          drop.push(table)
        else
          case opts[:no_exist]
          when :quiet
            # Do nothing. No message is printed
          when :abort
            raise(" * Table #{table} does not exist. Aborting.")
          else
            puts(" * Table #{table} does not exist. Skipping.")
          end
        end
        skips.push(table)
      end
      [
        drops.length > 0 ? "#{drops.length} tables dropped. #{drops}" : "No tables dropped",
        skips.length > 0 ? "#{skips.length} tables skipped. #{skips}" : nil,
      ].compact.join(", ")
    end

    # ALTER TABLE Queries: https://www.postgresql.org/docs/14/sql-altertable.html
    # Generic alter table statement. Provide table name and post
    def alter_table(table_name:, post:)
      sql = "ALTER TABLE #{table_name} #{post}"
      execute(sql: sql)
    end

    # ALTER TABLE distributors ADD COLUMN address varchar(30);
    def add_column(table_name:, column_name:, column_spec:, **opts)
      sql = "ADD COLUMN #{column_name} #{column_spec}"
      alter_table(table_name: table_name, post: sql)
    end

    def drop_column(table_name:, column_name:, **opts)
      sql = "DROP COLUMN #{column_name}"
      alter_table(table_name: table_name, post: sql)
    end

    def alter_column(table_name:, column_name:, column_spec:, **opts)
      sql = "ALTER COLUMN #{column_name} #{column_spec}"
      alter_table(table_name: table_name, post: sql)
    end

    # ALTER TABLE distributors RENAME COLUMN address TO city;
    def rename_column(table_name:, column_name:, new_column_name:, **opts)
      sql = "RENAME COLUMN #{column_name} TO #{new_column_name}"
      alter_table(table_name: table_name, post: sql)
    end

    def delete_rows(table_name:, **opts)
      where_str = opts[:where]
      sql = "DELETE FROM #{table_name} #{where_str}"
      execute(sql: sql)
    end

    #
    # - Schema Queries
    #

    def data_type_map
      {
        "character varying" => :string,
        "timestamp without time zone" => :datetime,
        "bigint" => :bigint,
        "jsonb" => :jsonb,
        "integer" => :integer,
      }
    end

    def table_rows(table_name)
      sql = "select count(*) from #{table_name}"
      execute(sql: sql)[0][:count].to_i
    end

    # Maps postgresql spec to rails spec
    # Given :data_type=>"timestamp without time zone", :is_nullable=>"NO", :datetime_precision=>"6"
    # Returns {type: :datetime, precision: 6, null: false }
    def parse_column_hash(**opts)
      rv = {}
      opts.each_pair { |key, value|
        if key == :data_type
          rv[:type] = data_type_map[value]
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

    # Creates {table: col_hash} for selected tables ~ schema.rb map
    def q_columns(**opts)
      rv = execute(sql: column_sql(**opts))
      return rv if opts[:format] == :raw
      col_hash = {}
      rv.each { |row|
        row.transform_keys! { |k| k.to_sym }
        col_hash[row[:table_name].to_sym] ||= {}
        col_spec = parse_column_hash(**row.except(:table_name, :column_name).compact.transform_keys { |k| k.to_sym })
        col_hash[row[:table_name].to_sym][row[:column_name].to_sym] = col_spec
      }
      col_hash
    end

    # For printable output use:
    #   c = PgCtl::Connection.new(db_name: :my_db)
    #   puts c.tables(format: :print)
    # List of tables in an array
    #   c.tables(names_only: true)
    # Default is a hash with {:name, :num_columns, :rows }
    #
    def q_tables(**opts)
      rv = execute(sql: table_sql(**opts))
      return rv if opts[:format] == :raw
      table_arr = rv.map { |row| row[:table_name] }
      return table_arr if opts[:names_only]

      # Add column counts and num rows to each table
      col_hash = q_columns
      tabs_list = table_arr.map { |t|
        {
          name: t,
          num_columns: col_hash[t.to_sym].length,
          rows: table_rows(t)
        }
      }
      return tabs_list.reduce({}) { |acc, obj| acc[obj[:name].to_sym] = obj.slice(:num_columns, :rows); acc } if opts[:format] == :hash
      return tabs_list unless opts[:format] == :print
      s_format = "%-32s %010s %08s"
      title = s_format % ["Name", "# columns", "# rows"]
      [
        title,
        tabs_list.map { |row| [s_format % [row[:name], row[:num_columns], row[:rows]]] }
      ].flatten.join("\n")
    end

    def filtered_tables(cond:, **opts)
      rv = q_tables(format: :hash)
      if cond == :blank
        rv.select{|a, b| b[:rows] == 0 }
      elsif cond == :non_blank
        rv.select{|a, b| b[:rows] > 0 }
      else
        rv
      end
    end

    module ClassMethods
    end
  end
end
