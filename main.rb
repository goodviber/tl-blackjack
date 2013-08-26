require 'rubygems'
require 'sinatra'

set :sessions, true

get '/form' do
	erb :form
end

post '/myaction' do
	puts params['username']
end