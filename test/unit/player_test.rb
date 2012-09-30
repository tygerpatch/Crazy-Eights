require 'test_helper'

class PlayerTest < ActiveSupport::TestCase

  def test_validates_uniqueness_of_name
    player_1 = players(:player_1)
    
    player = Player.new :name => player_1.name, :password => player_1.password
    assert !player.save    
  end  

  def test_validates_confirmation_of_password
    player = Player.new :name => "Ruby", :password => "Rails", :password_confirmation => "Grails"
    assert !player.save
  end

  def test_has_and_belongs_to_many_cards
    player = players(:player_1)
    player.cards.push cards(:ace_club), cards(:two_club)
    assert player.save
    
    assert player.cards.size >= 1
    
    assert player.cards.include? cards(:ace_club)
    assert player.cards.include? cards(:two_club)
  end

  def test_belongs_to_game
    game = Game.new
    assert game.save

    player = players(:player_1)
    player.game = game
    assert player.save

    assert_equal game, player.game
  end

  def test_my_turn    
    player_1 = players(:player_1)
    player_2 = players(:player_2)
    
    game = Game.new
    game.players.push player_1, player_2
    game.current_player = player_1.seat_order
    assert game.save
        
    assert_equal true, player_1.my_turn?
    assert_equal false, player_2.my_turn?    
  end

  def test_joinging_game
    game = Game.find(:first,
        :joins => :players,
        :group => "games.id",
        :having => "count(players.id) < 4")
    assert game.nil?
    
    player = players(:player_1)
    player.game = Game.new
    assert player.save
    
    game = Game.find(:first,
        :joins => :players,
        :group => "games.id",
        :having => "count(players.id) < 4")
    assert !game.nil?
    assert_equal player.game.id, game.id
  end

  def test_invalid_discard
    game = Game.new
    game.discard_pile << cards(:nine_diamond)
    assert game.save
    
    player = players(:player_1)
    player.cards.push cards(:five_spade), cards(:ace_club)
    player.game = game
    assert player.save
    
    assert_equal false, player.discard('5', 'spade')
    assert_equal 2, player.cards.size        
  end

  def test_valid_discard_crazy_eight
    game = Game.new
    game.discard_pile << cards(:nine_diamond)
    assert game.save
    
    player = players(:player_1)
    player.cards.push cards(:five_spade), cards(:eight_club)
    player.game = game
    assert player.save
    
    assert_equal true, player.discard('8', 'club')
    assert_equal 1, player.cards.size
    assert( player.cards.include? cards(:five_spade) )
  end

  def test_valid_discard_suit
    game = Game.new
    game.discard_pile << cards(:nine_diamond)
    assert game.save

    player = players(:player_1)
    player.cards.push cards(:five_spade), cards(:five_diamond)
    player.game = game
    assert player.save

    assert_equal true, player.discard('5', 'diamond')
    assert_equal 1, player.cards.size
    assert( player.cards.include? cards(:five_spade) )    
  end
  
  def test_valid_discard_rank
    game = Game.new
    game.discard_pile << cards(:nine_diamond)
    assert game.save

    player = players(:player_1)
    player.cards.push cards(:five_spade), cards(:nine_heart)
    player.game = game
    assert player.save

    assert_equal true, player.discard('9', 'heart')
    assert_equal 1, player.cards.size
    assert( player.cards.include? cards(:five_spade) )    
  end
  
  def test_end_turn
    game = Game.new
    assert game.save
    
    player = players(:player_1)
    player.game = game
    assert player.save

    assert_equal 0, game.current_player
    
    player.end_turn
    assert_equal 1, game.current_player
    
    player.end_turn
    assert_equal 2, game.current_player
    
    player.end_turn
    assert_equal 3, game.current_player
    
    player.end_turn
    assert_equal 0, game.current_player
  end
  
  def test_start_new_game
    player = players(:player_1)
    player.start_new_game
    assert_equal 5, player.cards.size
    assert player.save

    game = player.game
    assert_not_nil game
    
    # draw pile now has all the cards 
    # minus the one card the player has and the one card on top of the discard pile
    assert_equal 46, game.draw_pile.size

    player = players(:player_2)
    player.start_new_game
    assert_equal 5, player.cards.size
    assert player.save
    
    game = player.game
    assert_not_nil game
    assert_equal 41, game.draw_pile.size

    player = players(:player_3)
    player.start_new_game
    assert_equal 5, player.cards.size
    assert player.save
    
    game = player.game
    assert_not_nil game
    assert_equal 36, game.draw_pile.size
    
    player = players(:player_4)
    player.start_new_game
    assert_equal 5, player.cards.size
    assert player.save
    
    game = player.game
    assert_not_nil game
    assert_equal 31, game.draw_pile.size

    player = players(:player_5)
    player.start_new_game
    assert_equal 5, player.cards.size
    assert player.save
    
    game = player.game
    assert_not_nil game    
    assert_equal 46, game.draw_pile.size        
  end

  def test_draw_card    
    game = Game.new
    game.draw_pile.clear
    game.discard_pile.clear
    assert game.save
    
    assert_equal 0, game.draw_pile.size
    assert_equal 0, game.discard_pile.size
    
    five_diamond = Card.find_card('5', 'diamond')        
    assert_not_nil five_diamond
    
    game.discard_pile << five_diamond
    assert_equal 1, game.discard_pile.size
    
    three_club = Card.find_card('3', 'club')
    assert_not_nil three_club
    
    game.discard_pile << three_club
    assert_equal 2, game.discard_pile.size

    seven_heart = Card.find_card('7', 'heart')
    assert_not_nil seven_heart
    
    game.draw_pile << seven_heart
    assert_equal 1, game.draw_pile.size
            
    player = players(:player_1)
    player.game = game
    assert player.save
    
    player.draw_card
    
    assert_equal 1, player.cards.size
    assert_equal 1, game.draw_pile.size
    assert_equal 1, game.discard_pile.size
        
    assert player.cards.include?(seven_heart)    
    assert game.draw_pile.include?(five_diamond)
    assert game.discard_pile.include?(three_club)
        
    player.draw_card
        
    assert_equal 2, player.cards.size
    assert_equal 0, game.draw_pile.size
    assert_equal 1, game.discard_pile.size
    
    assert player.cards.include?(seven_heart)
    assert player.cards.include?(five_diamond)
    
    assert game.discard_pile.include?(three_club)
  end
  
  # TODO: when there's more than one card on discard pile and all the cards have been draw,
  # test that the right card is put back on the discard pile

end
