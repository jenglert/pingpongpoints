class WelcomeController < ApplicationController
  
  def index
  end
  
  def banner
    render :layout => 'banner'
  end
end
