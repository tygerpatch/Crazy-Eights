class Card < ActiveRecord::Base

  # Uniqueness of card is based on its rank and suit.
  validates_uniqueness_of :rank_id, :scope => :suit_id

  belongs_to :suit 	# card is dependent on suit
  belongs_to :rank 	# card is dependent on rank

  # Each player may hold many cards
  # and each card can appear in many player hands.
  has_and_belongs_to_many :players # join model CardsPlayers
  
  # Each game will have many cards on the draw pile
  # and each card may appear in many games (on the draw pile).
  has_and_belongs_to_many :draw_pile, :class_name => "Game", :join_table => "draw_pile" # will allow game.draw_pile

  # Each discard pile can have many cards.
  # And each card can be on many discard piles.
  has_and_belongs_to_many :discard_pile, :class_name => "Game", :join_table => "discard_pile" # will allow game.draw_pile

  def self.find_card(rank, suit)
    Card.find :first, :joins => [:rank, :suit],
      :conditions => ["ranks.name = ? AND suits.name = ?", rank, suit]
  end
  
  def is_an_eight?
    (0 == rank.name.casecmp('8'))
  end

  def has_same_rank_as(card)
    (0 == rank.name.casecmp(card.rank.name))
  end

  def has_same_suit_as(card)
    (0 == suit.name.casecmp(card.suit.name))
  end

end
