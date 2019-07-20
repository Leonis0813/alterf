class Evaluation < ActiveRecord::Base
  DATA_SOURCE_LIST = %w[file remote text].freeze

  validates :evaluation_id, :model, :data_source, :state,
            presence: {message: 'absent'}
  validates :evaluation_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: 'invalid'}
  validates :data_source,
            inclusion: {in: DATA_SOURCE_LIST, message: 'invalid'}
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'}

  has_many :data, dependent: :destroy

  def calculate_precision!
    positives = data.select do |datum|
      datum.prediction_results.map(&:number).include?(datum.ground_truth)
    end
    update!(precision: (positives.size.to_f / data.size).round(1))
  end
end
