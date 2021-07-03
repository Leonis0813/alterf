class Evaluation::Race < ApplicationRecord
  validates :race_id, :race_name, :race_url, :ground_truth,
            presence: {message: MESSAGE_ABSENT}
  validates :race_id,
            format: {with: /\A\d+\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :ground_truth,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: MESSAGE_INVALID,
            },
            allow_nil: true

  belongs_to :evaluation
  has_many :test_data,
           foreign_key: 'evaluation_race_id',
           dependent: :destroy

  after_create do
    attribute = slice(:race_name, :race_url).merge(
      'evaluation_id' => evaluation.evaluation_id,
      'no' => evaluation.data.size,
      'message_type' => 'create',
      )
    broadcast(attribute)
  end

  def import_prediction_results(result_file)
    race_result = YAML.load_file(result_file)
    raise ActiveRecord::RecordInvalid, self unless race_result.is_a?(Hash)

    race_result.each do |number, result|
      prediction_results.create!(number: number, won: (result == 1))
    end
    wons = prediction_results.won.pluck(:number).sort

    broadcast(num_entry: prediction_results.size, wons: wons, message_type: 'update')
  end

  private

  def broadcast(attribute)
    attribute.merge!(slice(:race_id, :ground_truth))
    attribute[:evaluation_id] = evaluation.evaluation_id
    ActionCable.server.broadcast('evaluation_datum', attribute)
  end
end
