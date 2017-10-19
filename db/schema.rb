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

ActiveRecord::Schema.define(version: 20171016213017) do

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
    t.string   "tags",                                     array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "serving_size"
    t.string   "image"
    t.integer  "creator_id"
    t.integer  "prep_time_mins"
    t.boolean  "is_private",               default: false
    t.tsvector "search_vector"
    t.integer  "cached_favorites_count"
    t.string   "purchase_info"
    t.boolean  "is_recipe_private",        default: false
    t.boolean  "is_purchasable",           default: false
    t.boolean  "is_recipe_given",          default: true
    t.integer  "state",                    default: 1
    t.datetime "state_changed_at"
    t.string   "source_url"
    t.integer  "cached_ratings_count"
    t.decimal  "cached_ratings_avg"
    t.datetime "processing_started_at"
    t.string   "processing_id"
    t.datetime "meta_graph_updated_at"
    t.datetime "meta_updated_at"
    t.jsonb    "meta"
    t.boolean  "is_feature_autorenewable", default: true
    t.integer  "feature_id"
    t.integer  "cached_comments_count"
  end

  add_index "dishes", ["meta_graph_updated_at"], name: "index_dishes_on_meta_graph_updated_at", using: :btree
  add_index "dishes", ["meta_updated_at"], name: "index_dishes_on_meta_updated_at", using: :btree
  add_index "dishes", ["processing_started_at"], name: "index_dishes_on_processing_started_at", using: :btree

  create_table "features", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "base_price"
    t.integer  "billable_amount"
    t.boolean  "is_cancelled"
    t.datetime "cancelled_at"
    t.datetime "finalized_at"
    t.integer  "dish_id"
    t.integer  "invoice_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "processing_started_at"
    t.string   "processing_id"
  end

  add_index "features", ["processing_started_at"], name: "index_features_on_processing_started_at", using: :btree

  create_table "followings", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: :cascade do |t|
    t.datetime "ending_at"
    t.integer  "total"
    t.integer  "amount_due"
    t.string   "stripe_charge_ids",     array: true
    t.datetime "charged_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount_paid"
    t.datetime "finalized_at"
    t.datetime "processing_started_at"
    t.string   "processing_id"
  end

  add_index "invoices", ["processing_started_at"], name: "index_invoices_on_processing_started_at", using: :btree

  create_table "locations", force: :cascade do |t|
    t.integer  "place_type"
    t.string   "city"
    t.string   "admin"
    t.string   "country"
    t.string   "country_iso2"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "postal_code"
    t.integer  "population"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
  end

  add_index "locations", ["uuid"], name: "index_locations_on_uuid", using: :btree

  create_table "user_reactions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "dish_id"
    t.boolean  "is_favorite"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
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
    t.integer  "notification_frequency",  default: 1
    t.datetime "last_notification_at"
    t.integer  "flags",                   default: [],    array: true
    t.boolean  "is_superadmin",           default: false
    t.integer  "cached_chefscore"
    t.integer  "cached_dishes_count"
    t.integer  "cached_followers_count"
    t.integer  "cached_followings_count"
    t.string   "full_name"
    t.integer  "location_ids",            default: [],    array: true
    t.datetime "processing_started_at"
    t.string   "processing_id"
    t.datetime "meta_graph_updated_at"
    t.datetime "meta_updated_at"
    t.jsonb    "meta"
    t.string   "stripe_customer_id"
  end

  add_index "users", ["meta_graph_updated_at"], name: "index_users_on_meta_graph_updated_at", using: :btree
  add_index "users", ["meta_updated_at"], name: "index_users_on_meta_updated_at", using: :btree
  add_index "users", ["processing_started_at"], name: "index_users_on_processing_started_at", using: :btree

end
