require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do

  BLACKJACK_AMOUNT = 21
  DEALER_MIN = 17
  ACE_VALUE = 11
  FACE_CARD_VALUE = 10

  def new_deck
    ranks = %w{ace 2 3 4 5 6 7 8 9 10 jack queen king}
    suits = %w{spades hearts diamonds clubs}
    session[:deck] = ranks.product(suits).each do |rank, suit|
    end
    session[:deck].shuffle!
  end

 def initialize_session
  new_deck
  session[:player_cards] = nil
  session[:dealer_cards] = nil
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
end

def show_deck
  "<img class='deck' src='/images/cards/card_deck.png' alt='Deck' />"
end

def show_cards(card)
  rank = card[0]
  suit = card[1]
  "<img class='cards' src='/images/cards/#{suit}_#{rank}.jpg' />"
end

def player_card_value(blackjack_players)
  card_values = 0
  players_cards = blackjack_players.map { |cards| cards[0]}
  players_cards.each do |card|
    if card == "Ace"
      card_values += ACE_VALUE
    elsif card.to_i == 0
      card_values += FACE_CARD_VALUE
    else
      card_values += card.to_i
    end
  end
  players_cards.select { |cards| cards == "Ace" }.count.times do
    if card_values > BLACKJACK_AMOUNT
      card_values -= FACE_CARD_VALUE
    end
  end
  card_values
end

def winner?
   if player_winner?  || dealer_winner? || no_winner?  || dealer_busted?  || player_busted? 
  @show_player_hit_stay = false
  @show_dealer_hit_stay = false
  @new_player_intro = false
  @dealer_turn_intro = false
  @player_next_intro = false
  @play_again = true

 end
end

def dealer_winner?
  @dealer_winner = "<h1 class='hit'>Dealer won!<br /></h1>"
  if player_card_value(session[:dealer_cards]) == BLACKJACK_AMOUNT
   return @dealer_winner
 elsif player_card_value(session[:dealer_cards]) > player_card_value(session[:player_cards]) && player_card_value(session[:dealer_cards]) < BLACKJACK_AMOUNT && player_card_value(session[:dealer_cards]) >=  DEALER_MIN && session[:hit_or_stay] == "Stay"
   return @dealer_winner
 elsif player_card_value(session[:dealer_cards]) < player_card_value(session[:player_cards]) && player_card_value(session[:player_cards]) > BLACKJACK_AMOUNT && player_card_value(session[:dealer_cards]) >=  DEALER_MIN && session[:hit_or_stay] == "Stay"
   return @dealer_winner
 end
end

def player_winner?
  @player_winner =  "<h1 class='hit'> #{session[:name]}, you won!<br /> </h1>"
  if player_card_value(session[:player_cards]) == BLACKJACK_AMOUNT
    return @player_winner
  elsif player_card_value(session[:player_cards]) > player_card_value(session[:dealer_cards]) && player_card_value(session[:player_cards]) <= BLACKJACK_AMOUNT && player_card_value(session[:dealer_cards]) >=  DEALER_MIN
    return @player_winner
  elsif  player_card_value(session[:player_cards]) < player_card_value(session[:dealer_cards]) && player_card_value(session[:dealer_cards]) > BLACKJACK_AMOUNT
    return @player_winner
  elsif player_card_value(session[:dealer_cards]) > BLACKJACK_AMOUNT  && player_card_value(session[:player_cards]) <= BLACKJACK_AMOUNT
    return @player_winner
  end
end

def no_winner?
  @no_winner = "<h1 class='hit'>No Winner!</h1>"
  @tie = "<h1 class='hit'>Its a tie</h1>"
  if player_card_value(session[:player_cards]) == BLACKJACK_AMOUNT &&  player_card_value(session[:player_cards]) == player_card_value(session[:dealer_cards])
    return @no_winner
  elsif player_card_value(session[:player_cards]) == BLACKJACK_AMOUNT &&  player_card_value(session[:player_cards]) == player_card_value(session[:dealer_cards]) && session[:hit_or_stay] == "Stay" && player_card_value(session[:dealer_cards]) >= 17
    return @tie
  elsif player_card_value(session[:player_cards]) == player_card_value(session[:dealer_cards])  && player_card_value(session[:dealer_cards]) >=  DEALER_MIN
    return @tie
  end
end

def dealer_busted?
  @dealer_busted = "<h1 class='hit'>Dealer busted!<br /></h1>"
  if player_card_value(session[:dealer_cards]) > BLACKJACK_AMOUNT
    return @dealer_busted
  end
end

def player_busted?
  @player_busted = "<h1 class='hit'> #{session[:name]}, you busted!<br /></h1>"
  if player_card_value(session[:player_cards]) > BLACKJACK_AMOUNT
    return @player_busted
  end
end
end

get '/' do
  erb :play
end

get '/play' do
  erb :play
end

post '/play' do
  session[:play] = params[:play]
  if session[:play]  == "No"
    redirect '/goodbye'
  else
   initialize_session
   redirect '/name'
 end
end

get '/name' do
  erb :name
end

post '/name' do
 session[:name] = params[:name]
 @last_player = session[:name]
 if session[:name] == nil
  session[:name] = @last_player
  session[:name] = params[:name]
end
session[:bet_amount] = "500"
redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/bet' do
  session[:bet] = params[:bet]
  redirect '/game'
end

get '/game' do
  @new_player_intro = true
  @show_player_hit_stay = true
  erb :game
end

post '/game/player/hit' do
  @show_player_hit_stay = true
  @show_dealer_hit_stay = false
  session[:hit_or_stay] = params[:hit_or_stay]
  session[:player_cards] << session[:deck].pop
  erb :game, layout: false
end


post '/game/player/stay' do
  session[:hit_or_stay] = params[:hit_or_stay]
  @show_player_hit_stay  = true
  @show_dealer_hit_stay = true
  erb :game, layout: false
end

post '/game/dealer/hit' do
session[:hit_or_stay] = params[:hit_or_stay]
  session[:dealer_cards] << session[:deck].pop
  erb :game, layout: false
end



post '/winner' do
  session[:play_again] = params[:play_again]
  @show_player_hit_stay = false
  @show_dealer_hit_stay = false
  if session[:play_again] == "No"
    redirect '/goodbye'
  else
    initialize_session
    redirect '/bet'
  end
end

get '/goodbye' do
  erb :goodbye
end
