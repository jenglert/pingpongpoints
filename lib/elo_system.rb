module EloSystem
  extend self
  include Math

  
  # K refers to the K rating of matches.  This number controls how quickly ratings will change.
  K = 16
  
  def calculate_rankings(matches)
    for match in matches
      chance_lower_rated_player_will_win = 1/(E ** (match.rating_difference/400.0) + 1)
      chance_higher_rated_player_will_win = 1 - chance_lower_rated_player_will_win
      
      # The expected result of the match can vary from 2.5 to 0.5.   2.5 would indicate that there is a very good chance
      # that the higher rated player will win, likely by a major victory margin.
      expected_score = 2.0 * (chance_higher_rated_player_will_win) + 0.5
      
      puts match.rating_difference
      puts "chance_higher_rated_player_will_win:" + chance_higher_rated_player_will_win.to_s
      puts "expected_score" + expected_score.to_s
      
      lrp = match.lower_rated_participant
      lrp.rating =  match.lower_rated_participant.rating + K * (match.lower_rated_participant_adj_score - expected_score)
      lrp.save!
      
      hrp = match.higher_rated_participant
      hrp.rating = match.higher_rated_participant.rating + K * (match.higher_rated_participant_adj_score - expected_score)  
      hrp.save!
    end
  end
  
end