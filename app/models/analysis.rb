class Analysis < ApplicationRecord
  validates :num_data, :num_tree, :state,
            presence: {message: 'absent'}
  validates :num_data, :num_tree,
            numericality: {only_integer: true, greater_than: 0, message: 'invalid'},
            allow_nil: true
  validates :num_feature,
            numericality: {only_integer: true, greater_than: 0, message: 'invalid'},
            allow_nil: true
  validates :num_entry,
            numericality: {only_integer: true, greater_than: 0, message: 'invalid'},
            allow_nil: true
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'},
            allow_nil: true
end
