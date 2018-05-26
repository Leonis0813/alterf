class PredictionJob < ActiveJob::Base
  queue_as :alterf

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    args = [prediction_id, prediction.model, prediction.test_data]
    ret = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
    prediction.update!(:state => 'completed')
    PredictionMailer.finished(prediction, ret).deliver_now
  end
end
