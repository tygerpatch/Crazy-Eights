require 'test_helper'

class GameTest < ActiveSupport::TestCase

  def test_has_many_players
    game = Game.new
    game.players.push players(:player_1), players(:player_2)
    assert game.save

    assert !(game.players.empty?)

    assert game.players.include? players(:player_1)
    assert game.players.include? players(:player_2)
    
    assert_equal 2, game.players.size
  end

  def test_has_and_belongs_to_many_draw_pile
    game = Game.new
    game.draw_pile.push cards(:ace_club), cards(:ace_diamond)
    assert game.save
    
    assert game.draw_pile.include? cards(:ace_club) # TODO: false is not true
    assert game.draw_pile.include? cards(:ace_diamond)
  end

  def test_has_and_belongs_to_many_discard_pile
    game = Game.new
    game.discard_pile.push cards(:ace_club), cards(:ace_diamond)
    assert game.save
    
    assert game.discard_pile.include? cards(:ace_club)
    assert game.discard_pile.include? cards(:ace_diamond)    
  end  

  def test_current_player
    player = players(:player_1)
    
    game = Game.new
    game.current_player = player.seat_order
    assert game.save

    assert_equal player.seat_order, game.current_player
  end

  def test_getting_game_based_on_number_of_players
    game = Game.new
    game.players.push players(:player_1), players(:player_2)
    assert game.save

    temp = Game.find :first,
      :joins => :players,
      :group => "games.id",
      :having => "count(players.id) < 4"

    assert_equal game.id, temp.id
    assert_equal game.players.size, temp.players.size
  end
  
  def test_game_initialization
    game = Game.new
    assert 51, game.draw_pile.size
    assert 1, game.discard_pile.size
  end  

end
