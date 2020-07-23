class Analysis
  class Result < ApplicationRecord
    belongs_to :analysis
    has_many :importances, foreign_key: 'analysis_result_id', dependent: :destroy
  end
end
