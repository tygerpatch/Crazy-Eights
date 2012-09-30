require 'test_helper'

class PlayingGameTest < ActionController::IntegrationTest
  #fixtures :all

  #logger = Logger.new(STDOUT)
  
  def test_game_setup
    create_deck

    # create players
    bottom_player = create_player('bottom', 'pass')
    left_player   = create_player('left', 'pass')
    top_player    = create_player('top', 'pass')
    right_player  = create_player('right', 'pass')

    # login players
    bottom_session = login_player( bottom_player )
    left_session   = login_player( left_player )
    top_session    = login_player( top_player )
    right_session  = login_player( right_player )

    # perform quick check of game setup
    check_status :seat_order => 0, :cards_in_hand => 5, :player => bottom_player
    check_status :seat_order => 1, :cards_in_hand => 5, :player => left_player
    check_status :seat_order => 2, :cards_in_hand => 5, :player => top_player
    check_status :seat_order => 3, :cards_in_hand => 5, :player => right_player

    # start game
    start_game bottom_session
    start_game left_session
    start_game top_session
    start_game right_session

    # check if player's turn
#    check_turn bottom_session, true
#    check_turn left_session, false
#    check_turn top_session, false
#    check_turn right_session, false

    # TODO: How to show player whose turn it is?  How to show player what was played?

    # logout players
    logout_player( bottom_session )
    logout_player( left_session )
    logout_player( top_session )
    logout_player( right_session )
  end


  # Test everything at least once.  Other way tested some things multiple times.
  #Center	:	9 Diamonds
  #Bottom	:	5 Spades, attempts to place 5 spades but fails, draws 10 Diamonds, places 10
  #Left   :	places King Diamonds, wins, end game
  #Top    :	checks to see if his turn and sees game has ended
  def test_winning_game
    logger = Logger.new(STDOUT)

    create_deck

    # create players
    bottom_player = create_player('bottom', 'pass')
    left_player   = create_player('left', 'pass')
    top_player    = create_player('top', 'pass')
    right_player  = create_player('right', 'pass')

    # login players
    bottom_session = login_player( bottom_player )
    left_session   = login_player( left_player )
    top_session    = login_player( top_player )
    right_session  = login_player( right_player )

    # start game
    start_game bottom_session
    start_game left_session
    start_game top_session
    start_game right_session

    # setup cards for demo
    bottom_player.cards.clear
    bottom_player.cards.push Card.find_card('5', 'spade')

    left_player.cards.clear
    left_player.cards.push Card.find_card('king', 'diamond')

    top_player.cards.clear
    top_player.cards.push Card.find_card('8', 'club')

    right_player.cards.clear
    right_player.cards.push Card.find_card('4', 'heart')

    bottom_player.reload
    left_player.reload
    top_player.reload
    right_player.reload

    # Center	:	9 Diamonds
    game = bottom_player.game

    game.discard_pile.clear
    game.discard_pile.push Card.find_card('9', 'diamond')

    game.draw_pile.clear
    game.draw_pile.push Card.find_card('10', 'diamond')
    # TODO: show draw_pile gets reshuffled when there are no more cards to draw

    assert game.valid?
    assert game.save(true)

    # bottom player goes first
    #check_turn(bottom_session, true)

    logger.info "\nright player tries to play the 4 of hearts, but is unable to because it's not his turn"

    # right player tries to play the 4 of hearts, but is unable to because it's not his turn
    right_session.xml_http_request :post, 'site/discard', {:rank => '4', :suit => 'heart', :id => 0}
    right_session.assert_equal 'discard(false, "0");', right_session.response.body

    logger.info "\nbottom player tries playing card not in hand, fail"

    # bottom player tries playing card not in hand, fail
    bottom_session.xml_http_request :post, 'site/discard', {:rank => 'king', :suit => 'heart', :id => 0}
    # TODO: I think id is index into array of cards on page.  It needs a more descriptive name.
    bottom_session.assert_equal 'discard(false, "0");', bottom_session.response.body

    game.reload
    assert_equal 1, game.discard_pile.length

    logger.info "\nbottom player attempts to place 5 spades but fails"

    # bottom player attempts to place 5 spades but fails
    bottom_session.xml_http_request :post, 'site/discard', {:rank => '5', :suit => 'spade', :id => 0}
    bottom_session.assert_equal 'discard(false, "0");', bottom_session.response.body

    game.reload
    assert_equal 1, game.discard_pile.length

    logger.info "\nbottom player draws 10 Diamonds"

    # bottom player draws 10 Diamonds
    bottom_session.xml_http_request :post, 'site/draw'
    bottom_session.assert_equal 'draw("10", "diamond");', bottom_session.response.body

    bottom_player.reload
    assert_equal 2, bottom_player.cards.length

    logger.info "\nbottom player discards 10 diamonds"

    # bottom player discards 10 diamonds
    bottom_session.xml_http_request :post, 'site/discard', {:rank => '10', :suit => 'diamond', :id => 1}
    bottom_session.assert_equal 'discard(true, "1");', bottom_session.response.body

    game.reload
    assert_equal 2, game.discard_pile.length

    bottom_player.reload
    assert_equal 1, bottom_player.cards.length

    # end of bottom player's turn
    #check_turn(bottom_session, false)

    # it is now the left player's turn
    #check_turn(left_session, true)

    logger.info "\nleft player discards king diamonds"

    # left player discards king diamonds
    left_session.xml_http_request :post, 'site/discard', {:rank => 'king', :suit => 'diamond', :id => 0}
    left_session.assert_equal 'discard(true, "0");', left_session.response.body

    left_player.reload
    assert_equal 0, left_player.cards.length

    # left player discarded their last card and has one the game
    game.reload
    assert game.has_ended

    # end of bottom player's turn
    #check_turn(left_session, false)

    # it is now the top player's turn
    #check_turn(top_session, true)

    logger.info "\ntop player tries to play 8 of clubs, but is unable to since the game has ended"

    # top player tries to play 8 of clubs, but is unable to since the game has ended
    top_session.xml_http_request :post, 'site/discard', {:rank => '8', :suit => 'club', :id => 0}
    top_session.assert_equal 'discard(false, "0");', top_session.response.body
  end

  private
  def create_deck
    ['club', 'heart', 'diamond', 'spade'].each do |name|
      suit = Suit.new :name => name
      assert suit.save(true)
    end

    ['ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king'].each do |name|
      rank = Rank.new :name => name
      assert rank.save(true)
    end

    ranks = Rank.find :all
    suits = Suit.find :all

    suits.each do |suit|
      ranks.each do |rank|
        unless Card.exists?({:rank_id => rank, :suit_id => suit})
          #Card.create :rank => rank, :suit => suit
          card = Card.new :rank => rank, :suit => suit
          card.save(true)
        end
      end
    end

    # make sure their's 52 cards
    assert_equal 52, Card.find(:all).count
  end

  def create_player(name, password)
    player = Player.new :name => name, :password => password
    assert player.save(true)

    return player
  end

  def login_player(player)
    player_session = open_session
    player_session.post '/site/login', :player => {:name => player.name, :password => player.password}
    player_session.assert_response :redirect
    
    player_session.follow_redirect!
    assert_equal '/site/waiting', player_session.path

    return player_session
  end

  def check_status( info )
    player = (info[:player]).reload
    # Note: Model might have changed since last time.  Get fresh data.  Don't rely on cache.

    assert_equal info[:seat_order], player.seat_order
    assert_equal info[:cards_in_hand], player.cards.length

    # Note: As a player, I only care about how many cards in my hand.  Not how many are in the draw pile.
    # Also don't care about the number of people playing.  Only care about when it's my turn.
    
    #assert_equal (52 - 5), bottom_player.game.draw_pile.count
    #assert_equal info[:number_players], player.game.players.length
  end

  def start_game(player_session)
    player_session.xml_http_request :post, 'site/start_game'
    player_session.assert_equal 'window.location.href = "/site/play_game";', player_session.response.body
    player_session.get '/site/play_game'
    player_session.assert_response :success
  end

#  def check_turn(player_session, flag)
#    player_session.xml_http_request :post, 'site/my_turn'
#    player_session.assert_equal "your_turn(#{flag});", player_session.response.body
#  end

  def logout_player(player_session)
    player_session.get '/site/logout'
    player_session.assert_response :redirect
    player_session.follow_redirect!
    assert_equal '/', player_session.path
    #assert_equal "/site/login", player_session.path
  end

end

