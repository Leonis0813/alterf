class Evaluation < ActiveRecord::Base
  DATA_SOURCE_LIST = %w[file remote text].freeze

  validates :evaluation_id, :model, :state,
            presence: {message: 'absent'}
  validates :evaluation_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: 'invalid'}
  validates :data_source,
            inclusion: {in: DATA_SOURCE_LIST, message: 'invalid'},
            allow_nil: true
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'}

  has_many :data, dependent: :destroy

  def fetch_data
    if data_source == 'remote'
      NetkeibaClient.new.http_get_race_top
    else
      file_path = Rails.root.join(
        'tmp',
        'files',
        id.to_s,
        Settings.evaluation.race_list_filename,
      )
      File.read(file_path).lines.map(&:chomp)
    end
  end

  def calculate!
    true_positive = data.inject do |tp, datum|
      tp + datum.prediction_results.where(number: datum.ground_truth, won: true).size
    end.to_f

    false_positive = data.inject do |fp, datum|
      fp + datum.prediction_results.where.not(number: datum.ground_truth, won: true).size
    end.to_f

    false_negative = data.inject do |fn, datum|
      fn + datum.prediction_results.where(number: datum.ground_truth, won: false).size
    end.to_f

    precision = true_positive / (true_positive + false_positive)
    recall = true_positive / (true_positive + false_negative)
    update!(
      precision: precision.round(3),
      recall: recall.round(3),
      f_measure: ((2 * precision * recall) / (precision + recall)).round(3),
    )
  end
end
