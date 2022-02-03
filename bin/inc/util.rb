# Common code for all scripts in this directory

require 'bundler/inline'
require "optparse"

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

# Check that *all* the keys are specified in options
def mandatory(opts:, parse:, keys:)
  missing = [keys].flatten.compact.filter_map{ |k| opts[k] ? nil : k }
  return if missing.length == 0
  puts ["These mandatory options are not provided: #{missing.join(', ')}", parse.help].join("\n")
end

# Parse options for script. mandatory options can be checked.
# padding check: :function_sym lets you write your own validations/checks
# opts = parse_options(mandatory: [:db1]) do |opt, res|
#   opt.on("-v", "--verbose", "Enable verbose mode.") { |v| res[:verbose] = v }
#   opt.on("-db1", "--db1 DATABASE1", "First database") { |v| res[:db1] = v }
#   opt.on("-db2", "--db2 DATABASE2", "Second database") { |v| res[:db2] = v }
#   opt.on("-t", "--table TABLE", "Table name.") { |v| res[:table] = v }
# end
def parse_options(check: nil, **opts)
  # puts opts.inspect
  parsed_opts = {}
  parser = OptionParser.new do |opt|
    yield(opt, parsed_opts)
  end
  parser.parse!

  if check
    self.send(check, opts: parsed_opts, parse: parser)
  elsif opts[:mandatory]
    mandatory(opts: parsed_opts, parse: parser, keys: opts[:mandatory])
  end

  parsed_opts
end