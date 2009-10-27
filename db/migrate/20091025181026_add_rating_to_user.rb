class AddRatingToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :rating, :integer, :default => 1500
  end

  def self.down
    drop_column :users, :rating
  end
end
