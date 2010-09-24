class AddTrialColumnToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :trial, :boolean, :default => false # if < true > => trial offer, if < false > => paid subscription offer
  end

  def self.down
    remove_column :offers, :trial
  end
end
