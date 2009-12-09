class UsersController < ApplicationController
  
  caches_page :new
  caches_page :show, :if => Proc.new { |c| !c.request.format.json? }
  
  # render new.rhtml
  def new
  end
  
  def show
    @user = User.find(params[:id])
    @matches = Match.find_by_user(@user.id)
    
    respond_to do |wants|
          wants.html {
            @graph = open_flash_chart_object( 600, 300, url_for( :action => 'show', :format => :json ) )
          }
          wants.json { 
            prev_score = 1500
            scores = @matches.collect { |x| prev_score = x.winner == @user ? prev_score + x.rating_change : prev_score - x.rating_change; prev_score}
            scores = [1500] + scores
            
            chart = OpenFlashChart.new( "Player Score" ) do |c|
              c << LineHollow.new( :values => scores, :text => 'Score', :max => 300 )
            end
            
            chart.set_y_axis(:max => scores.max + 50, :min => scores.min - 50, :steps => 30 )
            chart.set_x_axis(:steps => 3)
            chart.set_bg_colour('#EEEEFF')
            render :text => chart.render, :layout => false
          }
        end
  end

  def create
    # Expire the homepage
    clear_caches
    
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

end
