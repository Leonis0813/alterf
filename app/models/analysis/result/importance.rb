class Analysis
  class Result
    class Importance < ApplicationRecord
      validates :feature_name,
                uniqueness: {scope: 'analysis_result_id', message: 'duplicated_resource'}

      belongs_to :result
    end
  end
end
