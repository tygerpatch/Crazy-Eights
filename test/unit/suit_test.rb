require 'test_helper'

class SuitTest < ActiveSupport::TestCase

  def test_has_many_cards
    club = suits(:club)
    
    assert !(club.cards.empty?)    
    assert club.cards.size >= 1 
    
    assert club.cards.include? cards(:ace_club)
    assert club.cards.include? cards(:two_club)
  end

  def test_to_s    
    assert (0 == suits(:club).to_s().casecmp('club'))
  end

end
