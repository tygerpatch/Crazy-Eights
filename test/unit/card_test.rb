require 'test_helper'

class CardTest < ActiveSupport::TestCase

  def test_validates_uniqueness_of_rank_and_suit
    ace_club = cards(:ace_club)

    card = Card.new({
		:suit => ace_club.suit, 
		:rank => ace_club.rank})

    assert !card.save
  end

  def test_belongs_to_suit_rank
    ace_club = cards(:ace_club)
    
    assert_equal ranks(:ace).id, ace_club.rank.id
    assert_equal suits(:club).id, ace_club.suit.id
  end

  def test_has_and_belongs_to_many_players
    ace_club = cards(:ace_club)
    ace_club.players.push players(:player_1), players(:player_2)
    assert ace_club.save
    
    assert ace_club.players.include? players(:player_1) 
    assert ace_club.players.include? players(:player_2)
  end


  def test_has_and_belongs_to_many_games_draw_pile
    game_1 = Game.new
    assert game_1.save

    game_2 = Game.new
    assert game_2.save
        
    ace_club = cards(:ace_club)
    ace_club.draw_pile.push game_1, game_2 #games(:game_1), games(:game_2)
    assert ace_club.save
    
    assert ace_club.draw_pile.include? game_1 #games(:game_1)
    assert ace_club.draw_pile.include? game_2 #games(:game_2)
  end
  
  def test_has_and_belongs_to_many_games_discard_pile
    game_1 = Game.new
    assert game_1.save

    game_2 = Game.new
    assert game_2.save
        
    ace_club = cards(:ace_club)
    ace_club.discard_pile.push game_1, game_2 # games(:game_1), games(:game_2)
    assert ace_club.save
    
    assert ace_club.discard_pile.include? game_1 # games(:game_1)
    assert ace_club.discard_pile.include? game_2 # games(:game_2)
  end

  def test_find_card_method    
    card = Card.find_card 'ace', 'club'
    assert_not_nil card
    assert_equal cards(:ace_club).id, card.id
    
    card = Card.find_card '?', 'joker'
    assert_nil card
  end
          
  def test_is_an_eight
    assert_equal true, cards(:eight_club).is_an_eight?    
    assert_equal false, cards(:ace_club).is_an_eight?    
  end

  def test_has_same_rank_as
    assert_equal true, cards(:ace_club).has_same_rank_as(cards(:ace_diamond))
    assert_equal false, cards(:ace_club).has_same_rank_as(cards(:two_club))    
  end

  def test_has_same_suit_as
    assert_equal true, cards(:ace_club).has_same_suit_as(cards(:two_club))
    assert_equal false, cards(:ace_club).has_same_suit_as(cards(:ace_diamond))
  end

end

#logger = Logger.new(STDOUT)

