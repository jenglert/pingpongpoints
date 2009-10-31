class AddRatingChangeToMatch < ActiveRecord::Migration
  def self.up
    add_column :matches, :rating_change, :integer
  end

  def self.down
    remove_column :matches, :rating_change
  end
end
