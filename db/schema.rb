# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110812061511) do

  create_table "posts", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.string   "title",      :limit => 140, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id"], :name => "posts_users_fk"

  create_table "users", :force => true do |t|
    t.string   "username",   :limit => 12, :null => false
    t.string   "password",                 :null => false
    t.string   "full_name",  :limit => 30, :null => false
    t.string   "phone",      :limit => 20, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["phone"], :name => "users_phone_uidx", :unique => true
  add_index "users", ["username"], :name => "users_username_uidx", :unique => true

  add_foreign_key "posts", "users", :name => "posts_users_fk"

end
