require_relative "./config/environment"

class HelloWidgets < Sinatra::Base
  get '/' do
    "Hello Widgets! #{ Widgets.all.pluck(:name).join(', ') }"
  end

  set :port, PORT
  set :bind, BIND_ADDR

end

puts "Sinatra #{HelloWidgets.get :bind} #{HelloWidgets.get :port}"
HelloWidgets.run!