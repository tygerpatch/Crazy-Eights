require 'test_helper'

class RankTest < ActiveSupport::TestCase

  def test_has_many_cards
    ace = ranks(:ace)
    
    assert !(ace.cards.empty?)    
    assert ace.cards.size >= 1 
    
    assert ace.cards.include? cards(:ace_club)
    assert ace.cards.include? cards(:ace_heart)    
  end
  
  def test_to_s    
    assert (0 == ranks(:ace).to_s().casecmp('ace'))
  end
  
end
