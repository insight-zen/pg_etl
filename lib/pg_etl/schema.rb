module PgEtl
  module Schema
    def self.included(base)
      base.class_eval do
      end
      base.extend(ClassMethods)
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
    def columns(**opts)
      where_str = [
        "table_schema = 'public'",
        in_clause(field: :table_name, spec: opts[:tables]),
      ].compact.join(" AND ")
      sql = [
        "select table_name, column_name, data_type, is_nullable, column_default, character_maximum_length, datetime_precision, numeric_precision",
        "from information_schema.columns",
        "where #{where_str}",
        "order by table_name, column_name"
      ].compact.join(" ")
      rv = execute(sql: sql)
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
    def tables(**opts)
      sql = [
        "select table_name ",
        "from information_schema.tables",
        "where table_schema = 'public'",
        "order by table_name"
      ].compact.join(" ")
      table_arr = execute(sql: sql).map { |row| row[:table_name] }
      return table_arr if opts[:names_only]

      # Add column counts and num rows to each table
      col_hash = columns
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

    module ClassMethods
    end

  end
end