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

ActiveRecord::Schema.define(version: 20190720151828) do

  create_table "analyses", force: :cascade do |t|
    t.integer  "num_data",    limit: 4
    t.integer  "num_tree",    limit: 4
    t.integer  "num_feature", limit: 4
    t.string   "state",       limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "evaluation_data", force: :cascade do |t|
    t.integer  "evaluation_id", limit: 4,   null: false
    t.string   "race_name",     limit: 255, null: false
    t.string   "race_url",      limit: 255, null: false
    t.integer  "ground_truth",  limit: 4,   null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "evaluations", force: :cascade do |t|
    t.string   "evaluation_id", limit: 255,                    null: false
    t.string   "model",         limit: 255
    t.string   "data_source",   limit: 255, default: "remote", null: false
    t.string   "state",         limit: 255
    t.float    "precision",     limit: 24
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "prediction_results", force: :cascade do |t|
    t.integer  "predictable_id",   limit: 4,   null: false
    t.string   "predictable_type", limit: 255, null: false
    t.integer  "number",           limit: 4,   null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "predictions", force: :cascade do |t|
    t.string   "model",      limit: 255
    t.string   "test_data",  limit: 255
    t.string   "state",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
