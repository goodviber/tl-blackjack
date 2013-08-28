require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
	def calculate_total(cards)
		array=cards.map{|e| e[1]}
			total=0
		array.each do |a|
			if a=="A"
				total=total + 11
			elsif a.to_i==0
				total=total+10
			else
				total=total + a.to_i
			end
		end
		array.select{|e| e=="A"}.count.times do
			total=total-10 if total>21
		end
		total
	end
end

before do
	@show_hit_stay=true
end

get '/' do
	if session[:player_name]
		redirect '/game'
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

post '/game/player/hit' do
	session[:player_cards]<<session[:deck].pop
	if calculate_total(session[:player_cards])>21
		@error = "Looks like you busted"
		@show_hit_stay=false
	end
		erb :game
end

post '/game/player/stay' do
	@success = "You have chosen to stay..."
	@show_hit_stay=false
	erb :game
end
















