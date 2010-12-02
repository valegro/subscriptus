class AddArchives < ActiveRecord::Migration
  def self.up
    ActsAsArchive.update Subscription
  end

  def self.down
  end
end
