class MatchesController < ApplicationController
  
  before_filter :login_required, :only => [:new, :create]
  
  def new
    @match ||= Match.new(:home => current_user.id)
  end
  
  def show
    @match = Match.find(params[:id])
  end
  
  def index
    @matches = Match.paginate(:page => params[:page], :per_page => 15, :order => "created_at desc")
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
