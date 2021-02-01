class AddSpecificityToEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :evaluations, :specificity, :float, after: :recall
  end
end
