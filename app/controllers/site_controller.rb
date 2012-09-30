class SiteController < ApplicationController

  def logout
    session[:id] = nil
    redirect_to :action => :login
  end

  def login
    if request.post?
      player = Player.find_by_name_and_password params[:player][:name], params[:player][:password]

      unless player.nil?        
        session[:id] = player.id
        redirect_to :action => :waiting
      end
    end    
  end

  def discard
    player = Player.find session[:id]
    game = player.game

    # How to Use Boolean Columns
    # http://oldwiki.rubyonrails.org/rails/pages/HowtoUseBooleanColumns

    if player.my_turn? and !game.has_ended? and player.discard(params[:rank], params[:suit])
      player.end_turn
      render :js => "discard(#{true}, #{params[:id]});"
    else      
      render :js => "discard(#{false}, #{params[:id]});"
    end              
  end

  def draw
    player = Player.find session[:id]
    game = player.game
     
    if player.my_turn? && !game.has_ended?
      card = player.draw_card            
      render :js => "draw('#{card.rank}', '#{card.suit}');"
    else
      render :nothing => true      
    end
  end

    # TODO: Display error message if was playing but one of the players logged out

  def waiting
    player = Player.find session[:id]
    player.start_new_game
    player.save    
  end
     
  def start_game
    player = Player.find(session[:id])
    game = player.game
    
    if (game.players.size == 4)      
      session[:playing] = true
      redirect_to :controller => :site, :action => :play_game
    else
      render :nothing => true
    end                
  end

end



