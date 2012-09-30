class CreateGames < ActiveRecord::Migration

  def self.up
    create_table :games do |t|
      t.integer :current_player, :default => 0 # indicates whose turn it is, loops from 0 to 3, based on seat order
      t.integer :discard_pile_id
      t.boolean :has_ended, :default => false
        
      # TODO: delete game information when all the player's game_id don't match up with
      # When game ends, check how many player's still match.  When it gets to 1, delete game info.
    end
  end

  def self.down
    drop_table :games
  end
  
end
