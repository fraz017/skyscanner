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

ActiveRecord::Schema.define(version: 20160521141439) do

  create_table "airports", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "c_id",       limit: 255
    t.float    "latitude",   limit: 24
    t.float    "longitude",  limit: 24
    t.integer  "city_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "c_id",       limit: 255
    t.float    "latitude",   limit: 24
    t.float    "longitude",  limit: 24
    t.string   "iatacode",   limit: 255
    t.integer  "country_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "continents", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "c_id",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string   "c_id",         limit: 255
    t.string   "name",         limit: 255
    t.string   "currency",     limit: 255
    t.string   "language",     limit: 255
    t.integer  "continent_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "user_notifications", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.float    "price",      limit: 24
    t.text     "query",      limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

end
