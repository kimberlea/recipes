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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170417212120) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "body"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "ingredients"
    t.string   "directions"
    t.string   "tags",                           array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "serving_size"
    t.string   "image"
    t.string   "prep_time"
    t.integer  "creator_id"
    t.integer  "prep_time_mins"
    t.boolean  "is_private",     default: false
    t.tsvector "search_vector"
  end

  create_table "user_reactions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.boolean  "is_favorite"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistent_token"
    t.string   "perishable_token"
    t.datetime "perishable_token_exp"
    t.string   "picture"
    t.string   "bio"
  end

end
