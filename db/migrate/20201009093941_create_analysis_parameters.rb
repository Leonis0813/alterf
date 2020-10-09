class CreateAnalysisParameters < ActiveRecord::Migration[5.0]
  def up
    create_table :analysis_parameters do |t|
      t.references :analysis, null: false, index: {unique: true}
      t.integer :num_tree, null: false, default: 100
      t.integer :max_depth
      t.integer :min_samples_split, null: false, default: 2
      t.integer :min_samples_leaf, null: false, default: 1
      t.string :max_features, null: false, default: 'sqrt'
      t.integer :max_leaf_nodes
      t.timestamps null: false
    end

    Analysis.all.find_each do |analysis|
      analysis.create_parameter!(num_tree: analysis.num_tree)
    end

    remove_column :analyses, :num_tree
  end

  def down
    add_column :analyses, :num_tree, :integer, after: :num_data

    Analysis.all.find_each do |analysis|
      analysis.update!(num_tree: analysis.parameter.num_tree)
    end

    drop_table :analysis_parameters
  end
end
