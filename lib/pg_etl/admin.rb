# frozen_string_literal: true

module PgEtl
  class Admin
    # Targets the base catalog. Database based operations can be done here

    SqlTableList = "SELECT datname FROM pg_database WHERE datistemplate = false"
    class << self
      # Runs
      def run(sql:, **opts)
        Connection.run(db_name: "postgres", sql: sql, **opts)
      end

      def active_connections(db_name:, **opts)
        ssql = "SELECT * FROM pg_stat_activity WHERE datname = '#{db_name}'"
        run(sql: ssql).map { |r| r.slice(:pid, :datname, :username, :backend_start) } # r[:pid], r[:datname], r[:username], r[:backend_start]}
      end

      def has_active_connections?(db_name:, **opts)
        ac = active_connections(db_name: db_name)
        result = ac.length > 0 ? true : false
        return result unless opts[:format]
        { result: result, details: ac }
      end

      def databases(**opts)
        run(sql: SqlTableList, **opts).map { |row| row[:datname] }.sort
      end

      def database_exists?(db_name)
        databases.include?(db_name.to_s) ? true : false
      end

      def create_database(db_name:, **opts)
        raise("Database #{db_name} already exists") if database_exists?(db_name)
        run(sql: %Q!CREATE DATABASE "#{db_name}"!)
        result = database_exists?(db_name)
        return result if opts[:quiet]
        puts result ? " * Database #{db_name} created." : " ** Database #{db_name} could not be created."
      end

      def drop_database(db_name:, **opts)
        # puts "\n ** db_name: #{db_name}, opts: #{opts.inspect}, databases: #{Admin.databases}, exists?: #{database_exists?(db_name)}\n"
        if !database_exists?(db_name)
          if opts[:only_if_exists]
            puts " * Database #{db_name} does not exists. Skipping drop" if opts[:verbose]
            return false
          else
            puts("Database #{db_name} does not exist in drop_database.")
            return false
          end
        end
        if has_active_connections?(db_name: db_name)
          puts " * There are active connections to #{db_name}. Cannot continue with drop."
        end

        run(sql: %Q!DROP DATABASE "#{db_name}"!)
        result = database_exists?(db_name)
        return result if opts[:quiet]
        puts result ? " ** Database #{db_name} could not be dropped." : " * Database #{db_name} dropped."
      end

      # Rails Specific
      # Testing rails created many test databases
      # This method drops the extra test databases
      def drop_test_dbs
        db_list = databases
        databases.
          filter_map { |db_name| db_name if db_name =~ /\A(.*?)-(\d+)\z/ && db_list.include?($1) }.
          each { |db_name| drop_database(db_name) }
      end
    end
  end
end
