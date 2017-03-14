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

ActiveRecord::Schema.define(version: 20170309201439) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_settings", force: :cascade do |t|
    t.boolean "auto_translate",           default: true,            null: false
    t.boolean "is_private",               default: false,           null: false
    t.string  "app_title",                default: "Generic title", null: false
    t.string  "maintainer_email_address", default: "foo@bar.org"
    t.string  "translation_engine",       default: "bing",          null: false
  end

  create_table "announcement_translations", force: :cascade do |t|
    t.integer  "announcement_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "header"
    t.text     "content"
  end

  add_index "announcement_translations", ["announcement_id"], name: "index_announcement_translations_on_announcement_id", using: :btree
  add_index "announcement_translations", ["locale"], name: "index_announcement_translations_on_locale", using: :btree

  create_table "announcements", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "header",     null: false
    t.string   "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "announcements", ["user_id"], name: "index_announcements_on_user_id", using: :btree

  create_table "bootsy_image_galleries", force: :cascade do |t|
    t.integer  "bootsy_resource_id"
    t.string   "bootsy_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: :cascade do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_translations", force: :cascade do |t|
    t.integer  "category_id",                     null: false
    t.string   "locale",                          null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "name"
    t.boolean  "auto_translated", default: false, null: false
  end

  add_index "category_translations", ["category_id"], name: "index_category_translations_on_category_id", using: :btree
  add_index "category_translations", ["locale"], name: "index_category_translations_on_locale", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "sender_name"
    t.string   "sender_email"
    t.string   "subject"
    t.text     "text"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "tag"
  end

  create_table "place_translations", force: :cascade do |t|
    t.integer  "place_id",                        null: false
    t.string   "locale",                          null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "description"
    t.boolean  "auto_translated", default: false, null: false
    t.boolean  "reviewed",        default: false, null: false
  end

  add_index "place_translations", ["locale"], name: "index_place_translations_on_locale", using: :btree
  add_index "place_translations", ["place_id"], name: "index_place_translations_on_place_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.float    "latitude",                      null: false
    t.float    "longitude",                     null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "name",                          null: false
    t.string   "postal_code"
    t.string   "street"
    t.string   "house_number"
    t.string   "city"
    t.boolean  "reviewed",      default: false, null: false
    t.text     "categories",    default: ""
    t.string   "phone"
    t.string   "email"
    t.string   "homepage"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "event",         default: false, null: false
    t.string   "country"
    t.string   "district"
    t.string   "federal_state"
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                                     null: false
    t.string   "email",                                    null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "password_digest"
    t.boolean  "is_admin",                 default: false
    t.string   "password_reset_digest"
    t.datetime "password_reset_timestamp"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.string   "locale"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
