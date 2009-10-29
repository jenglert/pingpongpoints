class WelcomeController < ApplicationController
  
  def index
    @users_for_grid = initialize_grid(User)
  end
  
  def banner
    render :layout => 'banner'
  end
end
