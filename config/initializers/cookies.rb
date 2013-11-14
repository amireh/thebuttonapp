configure :test do
  set :credentials, { 'cookie' => { 'secret' => 'adooken' } }
end

configure :development, :production do
  config_file 'config/credentials.yml'
end

configure do
  use Rack::Session::Cookie, :secret => settings.credentials['cookie']['secret']
end
