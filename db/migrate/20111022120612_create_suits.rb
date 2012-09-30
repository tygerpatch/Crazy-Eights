class CreateSuits < ActiveRecord::Migration
  
  def self.up
    create_table :suits do |t|
      t.string :name # ex. 'Heart', 'Diamond'
    end
  end

  def self.down
    drop_table :suits
  end
  
end
