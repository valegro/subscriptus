class AddArchivePublication < ActiveRecord::Migration
  def self.up
    ActsAsArchive.update Publication
  end

  def self.down
  end
end
