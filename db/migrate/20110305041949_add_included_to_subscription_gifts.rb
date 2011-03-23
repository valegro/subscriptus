class AddIncludedToSubscriptionGifts < ActiveRecord::Migration
  def self.up
    add_column :subscription_gifts, :included, :boolean
  end

  def self.down
    remove_column :subscription_gifts, :included
  end
end
