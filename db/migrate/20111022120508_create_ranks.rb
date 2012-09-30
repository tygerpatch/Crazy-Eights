class CreateRanks < ActiveRecord::Migration

  def self.up
    create_table :ranks do |t|
      t.string :name # ex. 'Ace' or '2'
    end
  end

  def self.down
    drop_table :ranks
  end
  
end
