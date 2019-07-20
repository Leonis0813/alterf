class AddDataSourceToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations,
               :data_source,
               :string,
               null: false, default: 'remote', after: :model
  end
end
