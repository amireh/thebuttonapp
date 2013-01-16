# encoding: UTF-8

$ROOT ||= File.dirname(__FILE__)
$LOAD_PATH << $ROOT

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

# ----
# Validating that configuration files exist and are readable...
config_files = [ 'application', 'database' ]
config_files << 'credentials' unless settings.test?
config_files.each { |config_file|
  unless File.exists?(File.join($ROOT, 'config', "%s.yml" %[config_file] ))
    class ConfigFileError < StandardError; end;
    raise ConfigFileError, "Missing required config file: config/%s.yml" %[config_file]
  end
}

require 'config/initializer'

configure :test do
  set :credentials, { 'cookie' => { 'secret' => 'adooken' } }
end

configure :development, :production do
  config_file 'config/credentials.yml'
end

configure do
  config_file 'config/application.yml'
  config_file 'config/database.yml'

  mime_type :pdf, 'application/pdf'

  set :tmp_folder, File.join(settings.root, 'tmp')
  FileUtils.mkdir_p File.join(settings.tmp_folder, 'reports')

  use Rack::Session::Cookie, :secret => settings.credentials['cookie']['secret']

  dbc = settings.database
  # DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, "mysql://#{dbc[:un]}:#{dbc[:pw]}@#{dbc[:host]}/#{dbc[:db]}")

  # load everything
  [ 'lib', 'helpers', 'models', 'controllers' ].each { |d|
    Dir.glob("#{d}/**/*.rb").each { |f| require f }
  }

  DataMapper.finalize
  DataMapper.auto_upgrade! unless $DB_BOOTSTRAPPING

  helpers Gravatarify::Helper

  # Gravatarify.options[:default] = "wavatar"
  Gravatarify.options[:filetype] = :png
  Gravatarify.styles.merge!({
    mini:     { size: 16, html: { :class => 'gravatar gravatar-mini' } },
    icon:     { size: 32, html: { :class => 'gravatar gravatar-icon' } },
    default:  { size: 96, html: { :class => 'gravatar' } },
    profile:  { size: 128, html: { :class => 'gravatar' } }
  })

  PDFKit.configure do |config|
    config.default_options = {
      page_size: 'A4'
      # footer_left: '[webpage]',
      # footer_right: '[page]/[toPage]'
      # footer_spacing: 15.0,
      # footer_line: false
    }
  end
end

# skip OmniAuth and Pony in test mode
configure :development, :production do
  use OmniAuth::Builder do
    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }

    provider :developer if settings.development?
    provider :facebook, settings.credentials['facebook']['key'], settings.credentials['facebook']['secret']
    # provider :twitter,  settings.credentials['twitter']['key'],  settings.credentials['twitter']['secret']
    provider :google_oauth2,
      settings.credentials['google']['key'],
      settings.credentials['google']['secret'],
      { access_type: "offline", approval_prompt: "" }
    provider :github,   settings.credentials['github']['key'],  settings.credentials['github']['secret']
  end

  Pony.options = {
    :from => settings.courier[:from],
    :via => :smtp,
    :via_options => {
      :address    => settings.credentials['courier']['address'],
      :port       => settings.credentials['courier']['port'],
      :user_name  => settings.credentials['courier']['key'],
      :password   => settings.credentials['courier']['secret'],
      :enable_starttls_auto => true,
      :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain => "HELO", # don't know exactly what should be here
    }
  }
end

configure :production do
  Bundler.require(:production)
end

configure :development do
  Bundler.require(:development)
end
