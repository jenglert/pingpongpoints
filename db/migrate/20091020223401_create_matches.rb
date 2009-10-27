class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      
      t.integer :home
      t.integer :away
      t.integer :home_score
      t.integer :away_score
      t.integer :k
      
      t.timestamps
    end
  end

  def self.down
    drop_table :matches
  end
end
