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

ActiveRecord::Schema.define(version: 20160524120651) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categorizings", force: :cascade do |t|
    t.integer  "place_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "categorizings", ["category_id"], name: "index_categorizings_on_category_id", using: :btree
  add_index "categorizings", ["place_id"], name: "index_categorizings_on_place_id", using: :btree

  create_table "category_translations", force: :cascade do |t|
    t.integer  "category_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
  end

  add_index "category_translations", ["category_id"], name: "index_category_translations_on_category_id", using: :btree
  add_index "category_translations", ["locale"], name: "index_category_translations_on_locale", using: :btree

  create_table "place_translations", force: :cascade do |t|
    t.integer  "place_id",    null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  add_index "place_translations", ["locale"], name: "index_place_translations_on_locale", using: :btree
  add_index "place_translations", ["place_id"], name: "index_place_translations_on_place_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.float    "latitude",     null: false
    t.float    "longitude",    null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "name",         null: false
    t.string   "postal_code",  null: false
    t.string   "street",       null: false
    t.string   "house_number"
    t.string   "city",         null: false
  end

  add_foreign_key "categorizings", "categories"
  add_foreign_key "categorizings", "places"
end
