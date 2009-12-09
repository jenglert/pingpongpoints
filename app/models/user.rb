require 'digest/sha1'
class User < ActiveRecord::Base
  extend ActiveSupport::Memoizable 
  # Virtual attribute for the unencrypted password
  attr_accessor :password, :score

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  before_create :make_activation_code 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation

  def awards
    awards = []
    
    awards << "Winning Percentage Award" if winning_percentage_award
    awards << "Winning Streak Award" if winning_streak_award
    awards << "Losing Streak Award" if losing_streak_award
    awards << "Matches Played Award" if matches_played_award
    
    awards
  end
  memoize :awards

  def matches_played_award
    most_matches = Rails.cache.fetch("most_matches") {
      users = User.find(:all).sort{ |lhs, rhs| rhs.wins + rhs.losses <=> lhs.wins  + lhs.wins }
      users.first.wins + users.first.losses
    }
    
    self.wins + self.losses == most_matches    
  end

  def winning_percentage_award
    top_winning_percentage = Rails.cache.fetch("top_winning_percentage") {
      users = User.find(:all).sort{ |lhs,rhs| rhs.winning_percentage <=> lhs.winning_percentage }
      top_winning_percentage = users.first.winning_percentage
    }
    
    top_winning_percentage == self.winning_percentage
  end
  memoize :winning_percentage_award

  def losing_streak_award
    top_losing_streak = Rails.cache.fetch("top_losing_streak") {
      users = User.find(:all).sort { |lhs,rhs| rhs.losing_streak <=> lhs.losing_streak }
      users.first.losing_streak
    }
    
    self.losing_streak == top_losing_streak
  end
  memoize :losing_streak_award

  def winning_streak_award
    top_winning_streak = Rails.cache.fetch("top_winning_streak") {
      users = User.find(:all).sort { |lhs,rhs| rhs.winning_streak <=> lhs.winning_streak }
      users.first.winning_streak
    }
    
    top_winning_streak == self.winning_streak
  end
  memoize :winning_streak_award
  
  def rating
    rating = read_attribute(:rating)
    
    rating = rating + 25 if winning_percentage_award
    rating = rating + 25 if winning_streak_award
    rating = rating + 30 if losing_streak_award
    rating = rating + 25 if matches_played_award
    rating
  end

  def losing_streak
    matches_ordered_backwards = Match.find_by_user(self.id).sort {
      |lhs, rhs| rhs.created_at <=> lhs.created_at
    }
    
    loses = 0
    
    for match in matches_ordered_backwards
      if match.loser.id == self.id
        loses = loses + 1
      else
        return loses
      end
    end
    
    loses
  end
  memoize :losing_streak

  def winning_streak
    matches_ordered_backwards = Match.find_by_user(self.id).sort {
      |lhs, rhs| rhs.created_at <=> lhs.created_at
    }
    
    wins = 0
    
    for match in matches_ordered_backwards
      if match.winner.id == self.id
        wins = wins + 1
      else
        return wins
      end
    end
    
    wins
  end
  memoize :winning_streak
  
  def winning_percentage
    winning_percentage = 0
    winning_percentage = (self.wins.to_f / (self.wins.to_f + self.losses.to_f)) * 100 unless wins + losses == 0
    winning_percentage
  end
  memoize :winning_percentage
  
  def winning_percentage_string
    ("%3.1f" % self.winning_percentage) + '%'
  end
  
  def wins_versus(other_player)
    matches = Match.find_by_users(self.id, other_player.id)
    wins = 0
    
    for match in matches
      wins = wins + 1 if match.winner == self
    end 
    
     wins
  end
  
  def matches_versus(other_player)
    Match.find_by_users(self.id, other_player.id).length
  end
  
  def losses_versus(other_player)
    matches = Match.find_by_users(self.id, other_player.id)
    losses = 0
    
    for match in matches
      losses = losses + 1 if match.winner != self
    end 
    
    losses
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? or email = ?', login, login]
    
    if u && !u.active?
      u.errors.add_to_base "Please activate your account with the email you have recieved."
      return u
    end
    
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code

      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
end
