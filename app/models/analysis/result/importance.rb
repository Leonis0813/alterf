class Analysis
  class Result
    class Importance < ApplicationRecord
      validates :feature_name,
                uniqueness: {scope: 'analysis_result_id', message: MESSAGE_DUPLICATED}

      belongs_to :result,
                 foreign_key: 'analysis_result_id',
                 inverse_of: :importances
    end
  end
end
