class Suit < ActiveRecord::Base
  # Suit will appear on many cards.
  has_many :cards

  # This will help clean up some of the code.
  # Instead of having "card.suit.name", can now do just "card.suit"
  def to_s()
    "#{name}"
  end

end
