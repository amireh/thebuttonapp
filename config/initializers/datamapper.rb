configure do
  config_file 'config/database.yml'

  dbc = settings.database
  # DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, "mysql://#{dbc[:un]}:#{dbc[:pw]}@#{dbc[:host]}:#{dbc[:port] || 3306}/#{dbc[:db]}")

  # load everything
  [ 'ext', 'app/helpers', 'app/models', 'app/controllers' ].each { |d|
    Dir.glob("#{d}/**/*.rb").each { |f| require f }
  }

  DataMapper.finalize
  DataMapper.auto_upgrade! unless $DB_BOOTSTRAPPING
end