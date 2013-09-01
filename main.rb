require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT=21
DEALER_STAY=16
INITIAL_POT=500
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
			total=total-10 if total>BLACKJACK_AMOUNT
		end
		total
	end

	def win!(msg)
		@play_again=true
		@success="<bold>#{session[:player_name]} wins! #{msg}</bold>"
		@show_hit_stay=false
		session[:player_pot] += session[:player_bet]
	end

	def lose!(msg)
		@play_again=true
		@error="<bold>#{session[:player_name]} loses! #{msg}</bold>"
		@show_hit_stay=false
		session[:player_pot] -= session[:player_bet]
	end

	def tie!(msg)
		@play_again=true
		@success="<bold>It's a Draw! #{msg}</bold>"
		@show_hit_stay=false
	end

end

def card_image(card)

	suit=case card[0]
		when 'Hearts' then 'hearts'
		when 'Diamonds' then'diamonds'
		when 'Spades' then 'spades'
		when 'Clubs' then 'clubs'
	end
value=card[1]
	if ['J','Q','K','A'].include?(value)
	value = case card[1]
			when 'J' then 'jack'
			when 'Q' then 'queen'
			when 'K' then 'king'
			when 'A' then 'ace'
		end
	end

		"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"

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
	session[:player_pot] = INITIAL_POT
	erb :new_player
end

post '/new_player' do
	if params[:player_name].empty?
		@error = "Name is required"
		halt erb(:new_player)
	end
	session[:player_name] = params[:player_name]
#progress to game
	redirect '/bet'
end

get '/bet' do
	session[:player_bet]=nil
	erb :bet
end

post '/bet' do
	if params[:bet_amount].nil? || params[:bet_amount].to_i < 1
		@error="Please make a bet"
		halt erb(:bet)
	elsif params[:bet_amount].to_i > session[:player_pot].to_i
		@error="Cannot bet more than your pot...&pound#{session[:player_pot].to_i}"
		halt erb(:bet)
	else session[:player_bet] = params[:bet_amount].to_i
		redirect'/game'
	end
end


get '/game' do
	session[:turn] = session[:player_name]
	#set up game values
	suits=['Hearts', 'Diamonds', 'Clubs', 'Spades']
	values=['2','3','4','5','6','7','8','9','J','Q','K','A']
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
	if calculate_total(session[:player_cards])==BLACKJACK_AMOUNT

		win! ("#{session[:player_name]} hit blackjack!")

	elsif calculate_total(session[:player_cards])>BLACKJACK_AMOUNT

		lose! ("Looks like #{session[:player_name]} busted")

	end

		erb :game
end

post '/game/player/stay' do
	@success = "#{session[:player_name]} has chosen to stay..."
	@show_hit_stay=false
	if calculate_total(session[:player_cards])==BLACKJACK_AMOUNT
		win! ("#{session[:player_name]} hit blackjack!")
	end
	redirect '/game/dealer'

end

get '/game/dealer' do
	session[:turn]="Dealer"
	@show_hit_stay=false

	dealer_total=calculate_total(session[:dealer_cards])

	if dealer_total==BLACKJACK_AMOUNT
		lose!("Dealer hit blackjack!")
	elsif dealer_total>BLACKJACK_AMOUNT
		win!("Dealer busted at #{dealer_total}")
	elsif dealer_total>DEALER_STAY
		redirect '/game/compare'
	else

		@show_dealer_hit=true
					
	end

erb :game

end

post '/game/dealer/hit' do
			session[:dealer_cards]<<session[:deck].pop
			redirect '/game/dealer'
end

get '/game/compare' do
	@show_hit_stay=false
	player_total=calculate_total(session[:player_cards])
	dealer_total=calculate_total(session[:dealer_cards])

	if player_total<dealer_total
		lose!("Dealer has #{dealer_total}")

	elsif player_total>dealer_total
		win!("Dealer has #{dealer_total}")

	else
		tie!("Dealer and #{session[:player_name]} have #{player_total}")
	end

	 erb :game

end

get '/game_over' do
	erb :game_over
end
			











