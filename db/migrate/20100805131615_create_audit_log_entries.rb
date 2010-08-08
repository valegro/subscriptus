class CreateAuditLogEntries < ActiveRecord::Migration
  def self.up
    create_table :audit_log_entries do |t|
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :audit_log_entries
  end
end
