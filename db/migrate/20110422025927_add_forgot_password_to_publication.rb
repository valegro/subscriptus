class AddForgotPasswordToPublication < ActiveRecord::Migration
  def self.up
    change_table :publications do |t|
      t.string :forgot_password_link
    end
  end

  def self.down
    change_table :publications do |t|
      t.remove_column :forgot_password_link
    end
  end
end
