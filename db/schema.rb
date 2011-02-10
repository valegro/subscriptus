# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110210025503) do

  create_table "archived_subscriptions", :id => false, :force => true do |t|
    t.integer  "id"
    t.integer  "user_id"
    t.integer  "offer_id"
    t.integer  "publication_id"
    t.string   "state"
    t.string   "card_number"
    t.string   "card_expiration"
    t.string   "payment_method"
    t.decimal  "price"
    t.boolean  "auto_renew"
    t.datetime "state_updated_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "source_id"
    t.text     "referrer"
    t.boolean  "solus",            :default => false
    t.boolean  "weekender",        :default => true
    t.string   "pending"
    t.datetime "state_expires_at"
  end

  create_table "audit_log_entries", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "gift_offers", :force => true do |t|
    t.integer  "offer_id"
    t.integer  "gift_id"
    t.boolean  "included",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gifts", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "gift_image_file_name"
    t.string   "gift_image_content_type"
    t.integer  "gift_image_file_size"
    t.datetime "gift_image_updated_at"
    t.integer  "on_hand"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offer_terms", :force => true do |t|
    t.integer  "offer_id"
    t.decimal  "price"
    t.integer  "months"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offers", :force => true do |t|
    t.integer  "publication_id"
    t.string   "name"
    t.datetime "expires"
    t.boolean  "auto_renews"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "trial",          :default => false
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "gift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "state_updated_at"
    t.string   "state"
    t.integer  "subscription_id"
  end

  create_table "payments", :force => true do |t|
    t.string   "card_number"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "card_expiry_date"
    t.decimal  "amount"
    t.integer  "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_type"
    t.string   "reference"
  end

  create_table "publications", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "publication_image_file_name"
    t.string   "publication_image_content_type"
    t.integer  "publication_image_file_size"
    t.datetime "publication_image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sources", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_gifts", :force => true do |t|
    t.integer  "subscription_id"
    t.integer  "gift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_invoices", :force => true do |t|
    t.integer  "subscription_id"
    t.float    "amount"
    t.float    "amount_due"
    t.string   "invoice_number"
    t.integer  "harvest_invoice_id"
    t.string   "state"
    t.date     "state_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_log_entries", :force => true do |t|
    t.integer  "subscription_id"
    t.integer  "source_id"
    t.string   "old_state"
    t.string   "new_state"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_payments", :force => true do |t|
    t.integer  "subscription_id"
    t.integer  "amount"
    t.boolean  "success"
    t.string   "transaction_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subscription_invoice_id"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "offer_id"
    t.integer  "publication_id"
    t.string   "state"
    t.string   "card_number"
    t.string   "card_expiration"
    t.string   "payment_method"
    t.decimal  "price"
    t.boolean  "auto_renew"
    t.datetime "state_updated_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.text     "referrer"
    t.boolean  "solus",            :default => false
    t.boolean  "weekender",        :default => true
    t.string   "pending"
    t.datetime "state_expires_at"
  end

  create_table "transaction_logs", :force => true do |t|
    t.string   "recurrent_id"
    t.integer  "user_id"
    t.string   "action"
    t.decimal  "money"
    t.boolean  "success"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subscription_id"
    t.string   "order_num"
  end

  create_table "users", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "phone_number"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "postcode"
    t.string   "country"
    t.string   "title"
    t.string   "login",                            :null => false
    t.string   "crypted_password",                 :null => false
    t.string   "password_salt",                    :null => false
    t.string   "persistence_token",                :null => false
    t.integer  "login_count",       :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.boolean  "admin"
    t.boolean  "auto_created"
    t.string   "hear_about"
    t.string   "company"
  end

end
