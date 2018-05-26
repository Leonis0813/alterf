class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(:created_at => :desc)
  end

  def execute
    attributes = params.permit(*prediction_params)
    absent_keys = prediction_params - attributes.symbolize_keys.keys
    raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

    invalid_keys = attributes.select do |key, value|
      not value.respond_to?(:original_filename)
    end.keys
    unless invalid_keys.empty?
      raise BadRequest.new(invalid_keys.map {|key| "invalid_param_#{key}" })
    end

    prediction = Prediction.new(
      :model => attributes[:model].original_filename,
      :test_data => attributes[:test_data].original_filename,
      :state => 'processing'
    )
    if prediction.save
      PredictionJob.perform_later(prediction.id)
      render :status => :ok, :json => {}
    else
      raise BadRequest.new(prediction.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  private

  def prediction_params
    %i[ model test_data ]
  end
end
