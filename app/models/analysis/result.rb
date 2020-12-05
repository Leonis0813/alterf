class Analysis
  class Result < ApplicationRecord
    belongs_to :analysis
    has_many :importances,
             foreign_key: 'analysis_result_id',
             dependent: :destroy,
             inverse_of: :result
    has_many :decision_trees,
             foreign_key: 'analysis_result_id',
             dependent: :destroy,
             inverse_of: :result
  end
end
