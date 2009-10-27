class Match < ActiveRecord::Base
  validates_presence_of :home, :away, :home_score, :away_score
  
  # This is the number of points that one player will need in order to have a "major victory" over the other player.
  # A major victory will generate a larger swing in rating.
  MAJOR_DEFEAT_MARGIN = 5
  
  # Major victory = 3 points
  # Victory = 2 points
  # Loss = 1 points
  # Major Loss = 0 points
  MAJOR_VICTORY = 3
  VICTORY = 2
  LOSS = 1
  MAJOR_LOSS = 0
  
  def winner
    winning_participant true
  end
  
  def loser
    winning_participant false
  end
  
  def home_participant
    User.find(self.home)
  end
  
  def away_participant
    User.find(self.away)
  end
  
  def lower_rated_participant
    user = User.find(away_participant.rating < home_participant.rating ? away_participant : home_participant)
    user.score = participant_score user
    user
  end
  
  def higher_rated_participant
    user = User.find(away_participant.rating >= home_participant.rating ? away_participant : home_participant)
    user.score = participant_score user
    user
  end
  
  def rating_difference
    higher_rated_participant.rating - lower_rated_participant.rating
  end
  
  def lower_rated_participant_adj_score
    if lower_rated_participant.score > higher_rated_participant.score
      return lower_rated_participant.score - higher_rated_participant.score > MAJOR_DEFEAT_MARGIN ? MAJOR_VICTORY: VICTORY      
    else 
      return higher_rated_participant.score - lower_rated_participant.score > MAJOR_DEFEAT_MARGIN ? MAJOR_LOSS : LOSS
    end
  end
  
  def higher_rated_participant_adj_score
    if higher_rated_participant.score > lower_rated_participant.score
      return higher_rated_participant.score - lower_rated_participant.score > MAJOR_DEFEAT_MARGIN ? MAJOR_VICTORY: VICTORY      
    else 
      return lower_rated_participant.score - higher_rated_participant.score > MAJOR_DEFEAT_MARGIN ? MAJOR_LOSS : LOSS
    end
  end
  
private 

  def winning_participant(find_winner)
    participant = User.find(find_winner ^ (self.home_score > self.away_score)? self.away : self.home )
    participant.score = participant_score participant
    participant
  end
  
  def participant_score(participant)
    return self.home_score if participant.id == self.home
    return self.away_score if participant.id == self.away
    
    raise "Unable to determine participant score."
  end
  
end
