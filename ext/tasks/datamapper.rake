namespace :db do

  namespace :auto do

    desc "Perform auto-migration (reset your db data)"
    task :migrate => :environment do |t, _|
      puts "=> Auto-migrating"
      ::DataMapper.auto_migrate!
      puts "<= #{t.name} done"
    end

    desc "Perform non destructive auto-migration"
    task :upgrade => :environment do |t, _|
      puts "=> Auto-upgrading"
      ::DataMapper.auto_upgrade!
      puts "<= #{t.name} done"
    end

  end

  desc "Run all pending migrations, or up to specified migration"
  task :migrate, [:version] => :load_migrations do |t, args|
    if vers = args[:version] || ENV['VERSION']
      puts "=> Migrating up to version #{vers}"
      migrate_up!(vers)
    else
      puts "=> Migrating up"
      migrate_up!
    end
    puts "<= #{t.name} done"
  end

  desc "Rollback down to specified migration, or rollback last STEP=x migrations (default 1)"
  task :rollback, [:version] => :load_migrations do |t, args|
    if vers = args[:version] || ENV['VERSION']
      puts "=> Rolling back down to migration #{vers}"
      migrate_down!(vers)
    else
      step = ENV['STEP'].to_i || 1
      applied = migrations.delete_if {|m| m.needs_up?}.sort   # note this is N queries as currently implemented
      target = applied[-1 * step] || applied[0]
      if target
        puts "=> Rolling back #{step} step(s)"
        migrate_down!(target.position - 1)
      else
        warn "No migrations to rollback: #{step} step(s)"
      end
    end
    puts "<= #{t.name} done"
  end

  desc "List migrations descending, showing which have been applied"
  task :migrations => :load_migrations do
    puts migrations.sort.reverse.map {|m| "#{m.position}  #{m.name}  #{m.needs_up? ? '' : 'APPLIED'}"}
  end

  task :load_migrations => :environment do
    require 'dm-migrations/migration_runner'
    FileList['db/migrate/*.rb'].each do |migration|
      load migration
    end
  end


  desc "Create the database"
  task :create, [:repository] => :environment do |t, args|
    repo = args[:repository] || ENV['REPOSITORY'] || :default
    config = DataMapper.repository(repo).adapter.options.symbolize_keys
    user, password, host = config[:user], config[:password], config[:host]
    database       = config[:database]  || config[:path].sub(/\//, "")
    charset        = config[:charset]   || ENV['CHARSET']   || 'utf8'
    collation      = config[:collation] || ENV['COLLATION'] || 'utf8_unicode_ci'
    puts "=> Creating database '#{database}'"

    case config[:adapter]
    when 'postgres'
      system("createdb", "-E", charset, "-h", host, "-U", user, database)
    when 'mysql'
      query = [
        "mysql", "--user=#{user}", (password.blank? ? '' : "--password=#{password}"), (%w[127.0.0.1 localhost].include?(host) ? '-e' : "--host=#{host} -e"),
        "CREATE DATABASE #{database} DEFAULT CHARACTER SET #{charset} DEFAULT COLLATE #{collation}".inspect
      ]
      system(query.compact.join(" "))
    when 'sqlite3'
      DataMapper.setup(DataMapper.repository.name, config)
    else
      raise "Adapter #{config[:adapter]} not supported for creating databases yet."
    end
    puts "<= #{t.name} done"
  end

  desc "Drop the database"
  task :drop, [:repository] => :environment do |t, args|
    repo = args[:repository] || ENV['REPOSITORY'] || :default
    config = DataMapper.repository(repo).adapter.options.symbolize_keys
    user, password, host = config[:user], config[:password], config[:host]
    database       = config[:database] || config[:path].sub(/\//, "")
    puts "=> Dropping database '#{database}'"
    case config[:adapter]
      when 'postgres'
        system("dropdb", "-h", host, "-U", user, database)
      when 'mysql'
        query = [
          "mysql", "--user=#{user}", (password.blank? ? '' : "--password=#{password}"), (%w[127.0.0.1 localhost].include?(host) ? '-e' : "--host=#{host} -e"),
          "DROP DATABASE IF EXISTS #{database}".inspect
        ]
        system(query.compact.join(" "))
      when 'sqlite3'
        File.delete(config[:path]) if File.exist?(config[:path])
      else
        raise "Adapter #{config[:adapter]} not supported for dropping databases yet."
    end
    puts "<= #{t.name} done"
  end

  desc 'Load the seed data from db/seeds.rb'
  task :seed => :environment do |t, _|
    puts "=> Loading seed data"
    seed_file = File.expand_path('db/seeds.rb', File.dirname(__FILE__))
    load(seed_file) if File.exist?(seed_file)
    puts "<= #{t.name} done"
  end

  desc "Drop the database, migrate from scratch and initialize with the seed data"
  task :reset => [:drop, :setup]

  desc "Create the database, migrate and initialize with the seed data"
  task :setup => [:create, :migrate, :seed]

end