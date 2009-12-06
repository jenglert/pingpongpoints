class MatchObserver < ActiveRecord::Observer
  def after_create(match)
    rating_change = EloSystem.calculate_rankings match 
    
    match.winner.update_attribute :wins, match.winner.wins + 1
    match.loser.update_attribute :losses, match.loser.losses + 1
    
    tweet_match match
  end
  
  def tweet_match match
    httpauth = Twitter::HTTPAuth.new('pingpongpoints', 'zepher')
    client = Twitter::Base.new(httpauth)
    client.update("#{match.winner.login} #{ApplicationController.helpers.defeated_synonym} #{match.loser.login} #{match.winner.score}-#{match.loser.score}")
  
  rescue 
    # We don't care if tweeting doesn't work.
  end
end
