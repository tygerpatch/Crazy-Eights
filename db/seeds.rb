# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

ranks = ['ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king']

ranks.each do |name|
  rank = Rank.new :name => name
  rank.save
end

suits = ['heart', 'diamond', 'club', 'spade']

suits.each do |name|
  suit = Suit.new :name => name
  suit.save
end

ranks = Rank.find :all
suits = Suit.find :all
  
ranks.each do |rank|                                                                                             
	suits.each do |suit|
  		Card.create :rank => rank, :suit => suit
	end
end
