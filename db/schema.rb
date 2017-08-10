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

ActiveRecord::Schema.define(version: 20170810135133) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_events", force: :cascade do |t|
    t.string   "action"
    t.integer  "actor_id"
    t.integer  "dish_id"
    t.integer  "comment_id"
    t.integer  "user_id"
    t.jsonb    "meta",       default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "body"
    t.integer  "dish_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dishes", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "ingredients"
    t.string   "directions"
    t.string   "tags",                                   array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "serving_size"
    t.string   "image"
    t.integer  "creator_id"
    t.integer  "prep_time_mins"
    t.boolean  "is_private",             default: false
    t.tsvector "search_vector"
    t.integer  "cached_favorites_count"
    t.string   "purchase_info"
    t.boolean  "is_recipe_private",      default: false
    t.boolean  "is_purchasable",         default: false
    t.boolean  "is_recipe_given",        default: true
  end

  create_table "followings", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_reactions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "dish_id"
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
    t.integer  "notification_frequency", default: 1
    t.datetime "last_notification_at"
    t.integer  "flags",                  default: [],    array: true
    t.boolean  "is_superadmin",          default: false
  end

end
