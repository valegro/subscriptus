class AddSolusAndWeekenderToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :solus, :boolean, :default => false
    add_column :subscriptions, :weekender, :boolean, :default => true
  end

  def self.down
    remove_column :subscriptions, :solus
    remove_column :subscriptions, :weekender
  end
end
