class Evaluation < ActiveRecord::Base
  validates :evaluation_id, :model, :state,
            presence: {message: 'absent'}
  validates :evaluation_id,
            format: {with: /\A[0-9a-f]{16}\z/, message: 'invalid'}
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'}

  has_many :data, dependent: :destroy
end
