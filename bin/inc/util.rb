# Common code for all scripts in this directory

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem "hash_zen",  path: "~/dev/gems/hash_zen"
  gem "pg_etl",  path: "~/dev/gems/pg_etl"
end

# Expanded path relative to the current file
def relative_path(*opts)
  File.expand_path(File.join([File.dirname(__FILE__), opts].flatten))
end

# Expanded path relative to the rails root
def root_relative_path(*opts)
  relative_path(*["..", "..", opts].flatten)
end