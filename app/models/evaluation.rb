class Evaluation < ActiveRecord::Base
  validates :state, :inclusion => {:in => %w[ processing completed ]}
end
