class Match < ActiveRecord::Base
  validates_presence_of :home, :away, :home_score, :away_score
  
  named_scope :find_by_user, lambda { |*args| { :conditions => ['home = ? or away = ?', args.first, args.first] } }
  named_scope :find_by_users, lambda { |*args| { :conditions => ['(home = ? and away = ?) or (home = ? and away = ?)', args.first, args.second, args.second, args.first] } }
    
  VICTORY = 1
  LOSS = 0
  
  def winner
    winning_participant true
  end
  
  def loser
    winning_participant false
  end
  
  def home_participant
    user = User.find(self.home)
    user.score = participant_score user
    user
  end
  
  def away_participant
    user = User.find(self.away)
    user.score = participant_score user
    user
  end
  
  def other_participant(id)
    if self.away == id
      home_participant
    else
      away_participant
    end
  end
  
  def participant (id)
    if self.away != id
      home_participant
    else
      away_participant
    end
  end
  
  def won? (id)
    winner.id == id
  end
  
  def lower_rated_participant
    user = User.find(away_participant.rating_sans_awards < home_participant.rating_sans_awards ? away_participant : home_participant)
    user.score = participant_score user
    user
  end
  
  def higher_rated_participant
    user = User.find(away_participant.rating_sans_awards >= home_participant.rating_sans_awards ? away_participant : home_participant)
    user.score = participant_score user
    user
  end
  
  def rating_difference
    higher_rated_participant.rating_sans_awards - lower_rated_participant.rating_sans_awards
  end
  
  def lower_rated_participant_adj_score
    if lower_rated_participant.score > higher_rated_participant.score
      return VICTORY      
    else 
      return LOSS
    end
  end
  
  def higher_rated_participant_adj_score
    if higher_rated_participant.score > lower_rated_participant.score
      return VICTORY      
    else 
      return LOSS
    end
  end
  
private 

  def winning_participant(find_winner)
    participant = User.find(find_winner ^ (self.home_score > self.away_score) ? self.away : self.home )
    participant.score = participant_score participant
    participant
  end
  
  def participant_score(participant)
    return self.home_score if participant.id == self.home
    return self.away_score if participant.id == self.away
    
    raise "Unable to determine participant score."
  end
  
end
