class Game < ActiveRecord::Base
  # call validate only when card is put on discard_pile
  validate :validate_discard_pile

  # Each game will have many players (up to four).
  has_many :players 			# impractical to store reference to every player
  # TODO: validate limit of number of players

  # Each game will have many cards on the draw pile.
  # And each card may appear in many games (on the draw pile).
  has_and_belongs_to_many :draw_pile, :class_name => "Card", :join_table => "draw_pile" # will allow game.draw_pile

  # Each discard pile can have many cards.
  # And each card can be on many discard piles.
  has_and_belongs_to_many :discard_pile, :class_name => "Card", :join_table => "discard_pile"
  
	def validate_discard_pile
    # Only need to check when there's more than one card on the discard pile.
    # Otherwise, everything is fine.  (No errors are issued)
    if(self.discard_pile.length > 1 )      
      # take card off discard_pile
      length = self.discard_pile.length
      top_card = self.discard_pile[length - 1]

      # unless the top card is an 8
      unless (0 == top_card.rank.name.casecmp('8'))
        # take next card of discard pile
        second_card = self.discard_pile[length - 2]

        # unless the top two cards have same rank or suit
        unless((0 == top_card.rank.name.casecmp(second_card.rank.name)) ||
              (0 == top_card.suit.name.casecmp(second_card.suit.name)))
          # issue an error message          
          errors.add :discard_pile, 'card must either follow suit, rank, or else be an 8'
          # Note: Don't correct user's error
        end
      end
    end
  end

end

# logger = Logger.new(STDOUT)