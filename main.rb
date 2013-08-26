require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
	if session[:player_name]
		#progress to game
	else
		redirect '/new_player'
	end
end

get '/new_player' do
	erb :new_player
end

post '/new_player' do
	session[:player_name] = params[:player_name]
#progress to game
redirect '/game'

end

get '/game' do
	#set up game values
	suits=['Hearts', 'Diamonds', 'Clubs', 'Spades']
	values=['1','2','3','4','5','6','7','8','9','J','Q','K','A']
	session[:deck]=suits.product(values).shuffle

	session[:dealer_cards]=[]
	session[:player_cards]=[]
	
		session[:dealer_cards]<<session[:deck].pop
		session[:dealer_cards]<<session[:deck].pop
		session[:player_cards]<<session[:deck].pop
		session[:player_cards]<<session[:deck].pop
	
	#render template

	erb :game
end