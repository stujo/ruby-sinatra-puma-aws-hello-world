require "sinatra/base"


PORT = ENV['PORT'] || 3001
BIND_ADDR = ENV['BIND_ADDR'] || '0.0.0.0'

APP_NAME = ENV['APP_NAME'] || 'demo'

require "sinatra/activerecord"

require_relative '../models/widget'