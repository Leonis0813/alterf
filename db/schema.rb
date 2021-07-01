# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_01_114612) do

  create_table "analyses", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "analysis_id", default: "", null: false
    t.string "data_source"
    t.integer "num_data"
    t.integer "num_feature"
    t.string "state"
    t.datetime "performed_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "analysis_data", charset: "utf8", force: :cascade do |t|
    t.bigint "analysis_id", null: false
    t.string "race_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["analysis_id", "race_id"], name: "index_analysis_data_on_analysis_id_and_race_id", unique: true
    t.index ["analysis_id"], name: "index_analysis_data_on_analysis_id"
  end

  create_table "analysis_parameters", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "analysis_id", null: false
    t.integer "max_depth"
    t.string "max_features", default: "sqrt", null: false
    t.integer "max_leaf_nodes"
    t.integer "min_samples_leaf", default: 1, null: false
    t.integer "min_samples_split", default: 2, null: false
    t.integer "num_tree", default: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_analysis_parameters_on_analysis_id", unique: true
  end

  create_table "analysis_result_decision_tree_nodes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "analysis_result_decision_tree_id", null: false
    t.integer "node_id", null: false
    t.string "node_type", null: false
    t.string "group"
    t.string "feature_name"
    t.float "threshold"
    t.integer "num_win"
    t.integer "num_lose"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_result_decision_tree_id", "node_id"], name: "index_unique_analysis_result_decision_tree_id_node_id_on_nodes", unique: true
    t.index ["analysis_result_decision_tree_id"], name: "index_analysis_result_decision_tree_id_on_nodes"
  end

  create_table "analysis_result_decision_trees", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "analysis_result_id", null: false
    t.integer "tree_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_result_id", "tree_id"], name: "index_unique_analysis_result_id_tree_id_on_decision_trees", unique: true
    t.index ["analysis_result_id"], name: "index_analysis_result_decision_trees_on_analysis_result_id"
  end

  create_table "analysis_result_importances", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "analysis_result_id", null: false
    t.string "feature_name", null: false
    t.float "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_result_id", "feature_name"], name: "index_unique_analysis_result_id_feature_name_on_importances", unique: true
    t.index ["analysis_result_id"], name: "index_analysis_result_importances_on_analysis_result_id"
  end

  create_table "analysis_results", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "analysis_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_analysis_results_on_analysis_id", unique: true
  end

  create_table "evaluation_race_test_data", charset: "utf8", force: :cascade do |t|
    t.bigint "evaluation_race_id", null: false
    t.integer "number", null: false
    t.boolean "prediction_result"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["evaluation_race_id", "number"], name: "index_evaluation_race_test_data_on_evaluation_race_id_and_number", unique: true
    t.index ["evaluation_race_id"], name: "index_evaluation_race_test_data_on_evaluation_race_id"
  end

  create_table "evaluation_races", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "evaluation_id", null: false
    t.string "race_id", default: "", null: false
    t.string "race_name", null: false
    t.string "race_url", null: false
    t.integer "ground_truth", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "evaluations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "analysis_id"
    t.string "evaluation_id", null: false
    t.string "model"
    t.string "data_source", default: "remote", null: false
    t.integer "num_data", default: 0, null: false
    t.string "state"
    t.float "precision"
    t.float "recall"
    t.float "specificity"
    t.float "f_measure"
    t.datetime "performed_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_evaluations_on_analysis_id"
  end

  create_table "prediction_results", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "predictable_id", null: false
    t.string "predictable_type", null: false
    t.integer "number", null: false
    t.boolean "won", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "predictions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.bigint "analysis_id"
    t.string "prediction_id"
    t.string "model"
    t.string "test_data"
    t.string "state"
    t.datetime "performed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_predictions_on_analysis_id"
    t.index ["prediction_id"], name: "index_predictions_on_prediction_id", unique: true
  end

end
