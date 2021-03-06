# frozen_string_literal: true

require_relative "compare.rb"
require_relative "schema.rb"
require_relative "table.rb"
require_relative "column.rb"

module PgEtl
  class Connection
    include Compare
    include Schema

    # Manage a connection to a database.
    # Once instantiated the connection stays open. Be sure to close it
    # before gracefully existing the program.
    attr_accessor :connection, :name, :tables

    # Use db_name to refer to the database name. pg gem uses dbname.
    # This is the only place where the translation to non-underscore version is done
    def initialize(db_name:, **opts)
      @name, @opts, @tables = db_name, opts, []
      # host, port, options, tty, dbname, user, password
      @connection = PG.connect(dbname: @name, user: @opts[:user], password: @opts[:password])
      build_schema unless opts[:no_schema]
      "#{num_tables} in database #{name}"
    end

    # Run catalog query and build in memory Table structures with column information
    def build_schema(**opts)
      tables = q_tables(names_only: true)
      @tables = tables.map { |table|
        # col_array = q_columns(table: table, format: :raw)
        Table.new(name: table, db: self)
      }
    end

    def num_tables
      @tables.length
    end

    def table_exists?(name)
      table(name) ? true : false
    end

    def table(name)
      @tables.detect { |c| c.name == name.to_s }
    end

    def [](name)
      table_exists?(name) ? table(name) : raise("Table #{name} does not exist")
    end

    # Returned result is a symbolized hash.
    # If you want to fetch the result as PG::Result, specify (format: :raw)
    def execute(sql:, **opts)
      rv = connection.exec(sql)
      return rv if opts[:format] == :raw
      rv.map { |r| r.transform_keys { |k| k.to_sym } }
    end

    # Returns an IN clause for the query
    def in_clause(field:, spec:)
      return nil unless spec
      in_str = [spec].flatten.map { |s| "'#{s}'" }.join(", ")
      "#{field} in (#{in_str})"
    end

    def vacuum(**opts)
      execute(sql: "VACUUM FULL")
    end

    def close
      @name = nil
      connection.close
    end

    #
    # -- Backup and load for the current database
    #

    def dump(format: :plain, **opts)
      PgEtl::Admin.dump(format: format, db_name: @name, **opts)
    end

    def load(file:, **opts)
      PgEtl::Admin.load(file: file, db_name: @name, **opts)
    end

    # def format_ext_map
    #   {
    #     plain: ".txt",
    #     custom: ".sql "
    #   }
    # end

    # def output_file_name(format:, base: @name, **opts)
    #   [
    #     base,
    #     "_#{opts[:time_stamp] || Time.now.strftime('%Y%m%d_%H%M%S')}",
    #     format_ext_map[format],
    #   ].compact.join
    # end

    # def file_size(file:, **opts)
    #   return "No file: #{file}" unless File.exist?(file)
    #   fs = File.size(file)
    #   return "%d B" % fs if fs < 1024
    #   return "%0.1f KB" % (fs.to_f / 1024) if fs < 1048576
    #   "%0.2f MB" % (fs.to_f / 1048576) # (1024*1024))
    # end

    # def file_ctime(file:, **opts)
    #   return "No file: #{file}" unless File.exist?(file)
    #   File.ctime(file).strftime("%b %-m %Y, %I:%M %p")
    # end

    # # Output contains clean flag. Existing object will be dropeed when loading this file back in.
    # def dump(format: :plain, **opts)
    #   file = output_file_name(base: @name, format: format, **opts)
    #   s_command = "pg_dump --clean --format=#{format} -d #{@name} > #{file}"
    #   system(s_command)
    #   puts " * Dump written to file #{file} (#{file_size(file: file)}) in #{format} format." unless opts[:quiet]
    # end

    # def format_from_file(file)
    #   format_ext_map.invert[File.extname(file)]
    # end



    # def load(file:, **opts)
    #   format = format_from_file(file)
    #   user_opts = [
    #     @opts[:user] ? " -U #{@opts[:user]}" : nil
    #   ].compact.join

    #   s_command = if format == :plain
    #     "psql -d #{@name} #{user_opts} -f #{file} > /dev/null 2>&1"
    #   else
    #     "pg_restore --no-owner --no-acl --clean -d #{@name} #{user_opts} #{file} > /dev/null"
    #   end
    #   rv = system(s_command)
    #   puts " * Database loaded from file #{file} (#{file_size(file: file)})." unless opts[:quiet]
    #   rv
    # end

    class << self
      def open(db_name:, **opts)
        new(db_name: db_name)
      end

      def admin_run(sql:, **opts)
        Connection.run(db_name: "postgres", sql: sql, **opts)
      end

      # Open connection, run sql, and close connection
      def run(db_name:, sql:, **opts)
        c = new(db_name: db_name)
        rv = c.execute(sql: sql)
        c.close
        rv.map { |row| row }
      end
    end
  end
end
