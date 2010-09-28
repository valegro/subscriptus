class CreateTransactionLogs < ActiveRecord::Migration
  def self.up
    # this tables only holds the transactions with securePay gateway. no trial subscriptions.
    create_table :transaction_logs do |t|
      t.string  :recurrent_id # the recurrent id that is assigned to the subscription after an initial recurrent setup profile action
      t.integer :user_id      # the id of the user who is performing the subscription
      t.string  :action       # the recurrent action {setup, trigger, remove}
      t.decimal :money        # the money that is transfered during the transaction
      t.boolean :success      # was the transaction successful or not. value is included in the securePay XML response
      t.string  :message      # the success or failure message that is included in the securePay XML response

      t.timestamps
    end
  end

  def self.down
    drop_table  :transaction_logs
  end
end
