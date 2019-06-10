class Analysis < ActiveRecord::Base
  validates :num_data, :num_tree, :state,
            presence: {message: 'absent'}
  validates :num_data, :num_tree,
            numericality: {only_integer: true, greater_than: 0, message: 'invalid'}
  validates :num_feature,
            allow_nil: true,
            numericality: {only_integer: true, greater_than: 0, message: 'invalid'}
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'}
end
