class Evaluation < ApplicationRecord
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
  validates :precision, :recall, :f_measure,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1,
              message: 'invalid',
            },
            allow_nil: true

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
    true_positive = data.inject(0) do |tp, datum|
      tp + datum.prediction_results.won.where(number: datum.ground_truth).count
    end.to_f

    false_positive = data.inject(0) do |fp, datum|
      fp + datum.prediction_results.won.where.not(number: datum.ground_truth).count
    end.to_f

    false_negative = data.inject(0) do |fn, datum|
      fn + datum.prediction_results.lost.where(number: datum.ground_truth).count
    end.to_f

    precision = if (true_positive + false_positive).zero?
                  0.0
                else
                  true_positive / (true_positive + false_positive)
                end
    recall = if (true_positive + false_negative).zero?
               0.0
             else
               true_positive / (true_positive + false_negative)
             end
    f_measure = if (precision + recall).zero?
                  0.0
                else
                  (2 * precision * recall) / (precision + recall)
                end
    update!(precision: precision, recall: recall, f_measure: f_measure)
  end
end
