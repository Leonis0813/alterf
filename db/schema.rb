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

ActiveRecord::Schema.define(version: 20200723064309) do

  create_table "analyses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "analysis_id",  default: "", null: false
    t.integer  "num_data"
    t.integer  "num_tree"
    t.integer  "num_feature"
    t.integer  "num_entry"
    t.string   "state"
    t.datetime "performed_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "analysis_result_importances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "analysis_result_id",            null: false
    t.string   "feature_name",                  null: false
    t.float    "value",              limit: 24, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["analysis_result_id", "feature_name"], name: "index_unique_analysis_result_id_feature_name_on_importances", unique: true, using: :btree
    t.index ["analysis_result_id"], name: "index_analysis_result_importances_on_analysis_result_id", using: :btree
  end

  create_table "analysis_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "analysis_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["analysis_id"], name: "index_analysis_results_on_analysis_id", unique: true, using: :btree
  end

  create_table "evaluation_data", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "evaluation_id",              null: false
    t.string   "race_id",       default: "", null: false
    t.string   "race_name",                  null: false
    t.string   "race_url",                   null: false
    t.integer  "ground_truth",               null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "evaluations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "analysis_id"
    t.string   "evaluation_id",                               null: false
    t.string   "model"
    t.string   "data_source",              default: "remote", null: false
    t.integer  "num_data",                 default: 0,        null: false
    t.string   "state"
    t.float    "precision",     limit: 24
    t.float    "recall",        limit: 24
    t.float    "f_measure",     limit: 24
    t.datetime "performed_at"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.index ["analysis_id"], name: "index_evaluations_on_analysis_id", using: :btree
  end

  create_table "prediction_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "predictable_id",                   null: false
    t.string   "predictable_type",                 null: false
    t.integer  "number",                           null: false
    t.boolean  "won",              default: false, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "predictions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "prediction_id"
    t.string   "model"
    t.string   "test_data"
    t.string   "state"
    t.datetime "performed_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["prediction_id"], name: "index_predictions_on_prediction_id", unique: true, using: :btree
  end

end
