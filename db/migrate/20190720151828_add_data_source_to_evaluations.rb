class AddDataSourceToEvaluations < ActiveRecord::Migration[4.2]
  def change
    add_column :evaluations,
               :data_source,
               :string,
               null: false, default: 'remote', after: :model
  end
end
