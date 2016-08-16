port = ENV['PORT'] || 3002
puts "STARTING SINATRA on port #{port}"

require 'sinatra'

set :port, port
set :bind, '0.0.0.0'


get '/' do
  return 'Hello World!'
end