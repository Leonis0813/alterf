class Analysis
  class Result < ApplicationRecord
    belongs_to :analysis
    has_many :importances, dependent: :destroy
  end
end
