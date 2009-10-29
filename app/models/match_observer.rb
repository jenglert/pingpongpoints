class MatchObserver < ActiveRecord::Observer
  def after_save(match)
    EloSystem.calculate_rankings( [match] )
  end
end
