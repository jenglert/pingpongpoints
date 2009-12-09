  # Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include AuthenticatedSystem

  layout 'layout'

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  # Clears the caches for a user and matches
  # Accepts a list of match ids and user ids under the hash keys :matches and :users
  def clear_caches(options = {})
    # Clear the home page cache
    expire_page '/'
    expire_page :controller => "welcome", :action => "index"
    expire_page :controller => "matches", :action => "index"
    
    # Delete the cached values for these system calculations
    Rails.cache.delete("top_winning_streak")
    Rails.cache.delete("top_losing_streak")
    Rails.cache.delete("top_winning_percentage")
    Rails.cache.delete("most_matches")
    
    if options[:users].is_a?(Array)
      for user_id in options[:users]
        expire_page :controller => "users", :action => "show", :id => user_id
      end
    else
      expire_page :controller => "users", :action => "show", :id => options[:users]
    end
    
    if options[:matches].is_a?(Array)
      for match_id in options[:matches]
        expire_page :controller => "matches", :action => "show", :id => match_id
      end
    else
      expire_page :controller => "matches", :action => "show", :id => options[:matches]
    end

  end
end
