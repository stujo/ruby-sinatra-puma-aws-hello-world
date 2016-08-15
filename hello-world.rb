require 'sinatra'

class HelloWorld < Sinatra::Base
  get '/' do
    return 'Hello World!'
  end
end

if __FILE__ == $0
  HelloWorld.run!
end