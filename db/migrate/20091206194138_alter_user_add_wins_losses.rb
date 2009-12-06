class AlterUserAddWinsLosses < ActiveRecord::Migration
  def self.up
    add_column :users, :wins, :integer
    add_column :users, :losses, :integer
    User.reset_column_information
    
    # Update all the wins/losses for the users.
    for user in User.find(:all)
      user.update_attribute :wins, Match.find_by_user(user.id).reject { |m| m.winner.id != user.id }.length
      user.update_attribute :losses, Match.find_by_user(user.id).reject { |m| m.winner.id == user.id }.length
    end
  end

  def self.down
    drop_column :users, :wins
    drop_column :users, :losses
  end
end
