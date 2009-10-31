class MatchObserver < ActiveRecord::Observer
  def after_create(match)
    rating_change = EloSystem.calculate_rankings match 
  end
end
