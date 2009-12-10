class AddKToMatch < ActiveRecord::Migration
  def self.up
    add_column :matches, :k, :integer, :default => 64
    
    Match.reset_column_information
    
    for match in Match.find(:all)
      match.update_attribute :k, 64
    end
  end

  def self.down
  end
end
