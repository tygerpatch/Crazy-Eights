class CreateCardsPlayersJoinTable < ActiveRecord::Migration

	def self.up
		create_table :cards_players, :id => false do |t|
			t.integer :card_id
			t.integer :player_id
		end
	end

	def self.down
		drop_table :cards_players
	end
  
end

