class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.string :name
      t.string :password

      t.integer :seat_order
      t.integer :game_id
    end
  end

  def self.down
    drop_table :players
  end
end
