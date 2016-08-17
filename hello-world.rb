require_relative "./config/environment"

class HelloWidgets < Sinatra::Base
  get '/' do
    return "Hello Widgets! #{ Widget.all.pluck(:name).join(', ') }"
  end

  set :port, PORT
  set :bind, BIND_ADDR

end

puts "Sinatra #{BIND_ADDR} #{PORT}"
HelloWidgets.run!