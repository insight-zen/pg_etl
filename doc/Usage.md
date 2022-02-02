# Audit / Admin

A lot of information can be obtained by using using the command line

If using the local gem in the local repository use
```sh
 $ ./bin/console
```

## List of databases
```sh
 $ PgEtl::Admin.databases
```

## Load database from dump
```sh
 $ PgEtl::Admin.load(file:, db_name:)
```

## Dump a database
```sh
 $ PgEtl::Admin.dump(db_name:, format:)
```


Returns a list of databases. You can use one of these to follow along the single database section.

# Single Database

Make a persistent connection to a database and perform the DBA operations. Once connected, the connection ***persists***. Be sure to close it gracefully before exiting.

### Establish a connection

```ruby
  $ db = PgEtl::Connection.open(db_name: "foo101")
  $ db = PgEtl::Connection.new(db_name: "foo101")
```

Returns a connection to the database `foo101`. For the rest of the doc `db##` refers to an open connection to a Postgres database opened with `PgEtl::Connection.new`. The `open` class method is a convenience alias to create an instance of the Connection class.

### Close the connection
```ruby
  $ db.close
```

Closes the connection that was opened with `PgEtl::Connection.open`.

### List of tables
```ruby
 $ db.q_tables
```

Returns an array of tables. Each element is a hash with { name:, num_columns:, rows: }

### Zoom in on a table
```ruby
  $ users = db.tables(:insight_core_users)
```

users is a reference to the database table `insight_core_users`.

# Working in a project

## Adding pg_etl as a Gem

In the project Gemfile,
```ruby
gem "pg_etl"
```

or to reference a specific branch

```ruby
gem "pg_etl",   git: "git@github.com:insight-zen/pg_etl.git", branch: "main"
```

## Using in a IRB console

You can run console in that project by using the following command -

```shell
 $ bundle exec irb -r "pg_etl"
```

## Using in a script / standalone executable

```ruby
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem "pg_etl",  path: "~/dev/gems/pg_etl"
end
```



