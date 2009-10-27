# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  DEFEATED_SYNONYMS = ["whalloped", "defeated", "smashed", "whooped", "killed", "obliterated", "beat", "destroyed"]
  
  def other_users(current_user)
    User.find(:all) - [current_user]
  end
  
  def defeated_synonym
    DEFEATED_SYNONYMS[rand(DEFEATED_SYNONYMS.length)]
  end
  
  def top_ten_users
    User.find(:all, :order => 'rating desc')
    
  end
end
