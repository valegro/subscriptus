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

ActiveRecord::Schema.define(:version => 20110711044557) do

  create_table "archived_publications", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "name"
    t.text     "description"
    t.string   "publication_image_file_name"
    t.string   "publication_image_content_type"
    t.integer  "publication_image_file_size"
    t.datetime "publication_image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "forgot_password_link"
    t.integer  "default_renewal_offer_id"
    t.string   "template_name"
    t.string   "custom_domain"
    t.integer  "capabilities",                   :default => 0, :null => false
    t.string   "terms_url"
  end

  add_index "archived_publications", ["id"], :name => "index_archived_publications_on_id"

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
    t.string   "recurrent_id"
    t.string   "order_num"
    t.integer  "source_id"
    t.text     "referrer"
    t.boolean  "solus",             :default => false
    t.boolean  "weekender",         :default => true
    t.string   "pending"
    t.datetime "state_expires_at"
    t.integer  "term_length"
    t.boolean  "concession",        :default => false
    t.integer  "pending_action_id"
  end

  add_index "archived_subscriptions", ["id"], :name => "index_archived_subscriptions_on_id"

  create_table "audit_log_entries", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carrots", :force => true do |t|
    t.string   "state"
    t.datetime "state_updated_at"
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

  create_table "gifts_offers", :force => true do |t|
    t.integer "gift_id"
    t.integer "offer_id"
  end

  create_table "offer_terms", :force => true do |t|
    t.integer  "offer_id"
    t.decimal  "price"
    t.integer  "months"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "concession", :default => false
  end

  create_table "offers", :force => true do |t|
    t.integer  "publication_id"
    t.string   "name"
    t.datetime "expires"
    t.boolean  "auto_renews"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "trial",          :default => false
    t.boolean  "primary_offer",  :default => false
  end

  add_index "offers", ["name"], :name => "index_offers_on_name", :unique => true

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
    t.boolean  "has_delivery_address", :default => false, :null => false
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "phone_number"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "address_state"
    t.string   "postcode"
    t.string   "country"
  end

  create_table "payments", :force => true do |t|
    t.string   "card_number"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "card_expiry_date"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_type"
    t.string   "reference"
    t.integer  "subscription_action_id"
    t.datetime "processed_at"
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
    t.string   "forgot_password_link"
    t.integer  "default_renewal_offer_id"
    t.string   "template_name"
    t.string   "custom_domain"
    t.integer  "capabilities",                   :default => 0, :null => false
    t.string   "terms_url"
  end

  add_index "publications", ["name"], :name => "index_publications_on_name", :unique => true

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

  create_table "subscription_actions", :force => true do |t|
    t.string   "offer_name"
    t.integer  "term_length"
    t.integer  "source_id"
    t.integer  "subscription_id"
    t.datetime "applied_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "renewal",         :default => false
    t.datetime "old_expires_at"
    t.datetime "new_expires_at"
  end

  create_table "subscription_gifts", :force => true do |t|
    t.integer  "subscription_action_id"
    t.integer  "gift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "included",               :default => false
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
<<<<<<< HEAD
=======
    t.string   "recurrent_id"
    t.string   "order_num"
>>>>>>> master
    t.integer  "source_id"
    t.text     "referrer"
    t.boolean  "solus",             :default => false
    t.boolean  "weekender",         :default => true
    t.string   "pending"
    t.datetime "state_expires_at"
    t.integer  "term_length"
    t.boolean  "concession",        :default => false
    t.integer  "pending_action_id"
  end

  add_index "subscriptions", ["publication_id"], :name => "index_subscriptions_on_publication_id"

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
    t.string   "login"
    t.string   "crypted_password",                           :null => false
    t.string   "password_salt",                              :null => false
    t.string   "persistence_token",                          :null => false
    t.integer  "login_count",             :default => 0,     :null => false
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
    t.boolean  "valid_concession_holder", :default => false
    t.string   "payment_gateway_token"
    t.string   "gender"
    t.string   "perishable_token",        :default => "",    :null => false
    t.string   "next_login_redirect"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
