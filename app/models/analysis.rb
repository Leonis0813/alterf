class Analysis < ApplicationRecord
  validates :analysis_id, :num_data, :num_tree, :state,
            presence: {message: 'absent'}
  validates :analysis_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: 'invalid'}
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

  has_many :predictions, dependent: :destroy
  has_many :evaluations, dependent: :destroy
end
