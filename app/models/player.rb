class Player < ActiveRecord::Base

  validates_uniqueness_of :name
  validates_confirmation_of :password

  # Player is involved in a game.  
  # That is, player is dependent on game.
  belongs_to :game

  # Each player may hold many cards.
  # Each card can appear in many player hands.
  has_and_belongs_to_many :cards # join model CardsPlayers

	def my_turn?
	  seat_order == game.current_player
	end	  

	def draw_card
	  
	  if (game.draw_pile.size == 0) && (game.discard_pile.size == 1)	    
      # Fixes drawing 'extra' (random) cards.  
      # This happens when all the cards have been drawn
      # and there's only one card on the discard pile.
	    
	    return nil
	  end
	  
	  card = game.draw_pile.pop	  
	  game.draw_pile.delete card # Fixes drawing the same card over and over again
	  
	  cards.push card		
	  
    # Wait until all the cards have been drawn before reshuffling
    if game.draw_pile.size <= 0      
      
      # Take all the discarded cards
      game.draw_pile.replace game.discard_pile 
            
      # (except for the one at the top)
      game.discard_pile.clear
      
      pop_card = game.draw_pile.pop
      game.draw_pile.delete pop_card
      game.discard_pile << pop_card
                  
      # and shuffle them.
      game.draw_pile.shuffle!      
    end
    
    return card
  end

  # It makes more sense to say the player discards a card
  # than for the game discards it.
  # Also follows Fat Model, Skinny Controller principal.
	def discard(rank, suit)
		card = Card.find_card rank, suit
		
		unless cards.exists? card
			return false
		end

		if card.is_an_eight?
		  cards.delete(card)
		  game.discard_pile << card
		  return true
		  
      # "Adding an object to a collection (has_many or 
      # has_and_belongs_to_many) automatically saves that object,
      # except if the parent object (the owner of the collection) 
      # is not yet stored in the database."

      # <http://api.rubyonrails.org/classes/ActiveRecord/Associations/
      # ClassMethods.html>		  
		end
		
    top_discard = game.discard_pile.last
    # Note: Assumes there's always a card on the discard pile
				
    if ((card.has_same_rank_as top_discard) or (card.has_same_suit_as top_discard))
      cards.delete(card)
      game.discard_pile << card               
      game.save
      return true
    else
      return false
    end
  end        

  def end_turn
    game.has_ended = (cards.size == 0)    
    game.current_player = game.current_player + 1    
    game.current_player = 0 if game.current_player > 3
    game.save
  end
 
  def start_new_game    
    # join the first game with less than 4 players
    game = Game.find(:first,
        :joins => :players,
        :group => "games.id",
        :having => "count(players.id) < 4")
        
    game = Game.new if game.nil?
        
    self.cards.clear
    self.game = game	  	  
    self.seat_order = game.players.size
    
    # Each player draws (ie. dealt) 5 cards
	  5.times do ||
      card = game.draw_pile.pop()
	    self.cards.push card	    
	    game.draw_pile.delete(card)
	  end    
  end

end

