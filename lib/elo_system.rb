module EloSystem
  extend self
  include Math

  # K refers to the K rating of matches.  This number controls how quickly ratings will change.
  K = 64
  
  # This is the number of points that one player will need in order to have a "major victory" over the other player.
  # A major victory will generate a larger swing in rating.
  MAJOR_DEFEAT_MARGIN = 5
  
  def recalculate_all_rankings
    # Reset all data to the original state
    User.find(:all).each{ |u| u.update_attribute :rating, 1500 }
    
    # Reset all rankings
    Match.find(:all, :order => 'created_at asc').each { |m| calculate_rankings m }
  end
  
  def calculate_rankings(match)
    
    chance_higher_rated_player_will_win = calculate_higher_rated_players_chance_to_win match.rating_difference
    
    margin_of_victory_mulitiplier = 1.0
    
    if match.winner.score - match.loser.score > MAJOR_DEFEAT_MARGIN
      margin_of_victory_mulitiplier = 1.5
    end
    
    rating_change = (margin_of_victory_mulitiplier * K * (match.higher_rated_participant_adj_score - chance_higher_rated_player_will_win)).round.abs
    
    match.winner.update_attribute :rating, match.winner.rating + rating_change
    match.loser.update_attribute :rating, match.loser.rating - rating_change
    
    # Return the number of points that each player's rating will change by potentially.
    match.update_attribute :rating_change, rating_change.abs
  end
  
  # Calculates the % chance that the higher rated player will win based on the rating difference.
  def calculate_higher_rated_players_chance_to_win(rating_difference)
    1 - 1/(E ** (rating_difference.abs/200.0) + 1)
  end
  
end