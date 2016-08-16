require "sinatra/base"

PORT = ENV['PORT'] || 3001
BIND_ADDR = ENV['BIND_ADDR'] || '0.0.0.0'
puts "STARTING SINATRA on #{BIND_ADDR} #{PORT}"


class HelloWorld < Sinatra::Base
  get '/' do
    return 'Hello World!'
  end

  set :port, PORT
  set :bind, BIND_ADDR

end

HelloWorld.run!