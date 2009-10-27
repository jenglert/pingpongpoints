class MatchesController < ApplicationController
  def new
    @match ||= Match.new(:home => current_user.id)
  end
  
  def show
    @match = Match.find(params[:id])
  end
  
  def index
    @matches = Match.find(:all, :order => "created_at desc")
  end
  
  def create
    @match = Match.new(params[:match])
    
    if @match.save
      flash[:notice] = "Match added!"
      redirect_to @match
    else
      render :action => 'new'
    end
  end
end
