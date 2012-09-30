require 'test_helper'

class SiteControllerTest < ActionController::TestCase

  def test_login_failed
    player = players(:player_1)        
    post :login, :player => {:name => player.name, :password => 'not' + player.password}
    
    assert_response :success 
    assert_nil session[:id]  
  end

  def test_login_success 
    player = players(:player_1)        
    post :login, :player => {:name => player.name, :password => player.password}
    
    assert_redirected_to :action => :waiting
    assert_equal player.id, session[:id]

    player = Player.find session[:id]
        
    assert_equal 0, player.seat_order
    assert_equal 5, player.cards.size

    game = player.game

    assert_equal 1, game.discard_pile.size
        
    # 52 total cards - 1 card on discard pile - 5 cards in player's hand
    assert_equal 46, game.draw_pile.size    
  end

  def test_logout_success
    test_login_success

    get :logout
    assert_redirected_to :action => 'login'
    assert_nil session[:id]
  end
  
end

#logger = Logger.new(STDOUT)
