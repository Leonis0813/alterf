class AddNumDataToEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :evaluations, :num_data, :integer,
               null: false, default: 0, after: :data_source
  end
end
