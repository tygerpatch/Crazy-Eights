class Rank < ActiveRecord::Base
  # Rank will appear on many cards.
  has_many :cards 

  # This will help clean up some of the code.
  # Instead of having "card.rank.name", can now do just "card.rank"
  def to_s()
    "#{name}"
  end

end
