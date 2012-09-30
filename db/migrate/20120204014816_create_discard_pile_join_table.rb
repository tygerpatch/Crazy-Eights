class CreateDiscardPileJoinTable < ActiveRecord::Migration

  def self.up
    create_table :discard_pile, :id => false do |t|
      t.integer :game_id
      t.integer :card_id
    end
  end

  def self.down
    drop_table :discard_pile
  end

end
