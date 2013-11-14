ENV['TZ'] = 'UTC'

require './app'
use Rack::ShowExceptions
run Sinatra::Application