class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(:created_at => :desc)
  end

  def execute
    attributes = params.permit(*prediction_params)
    absent_keys = prediction_params - attributes.symbolize_keys.keys
    raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

    invalid_keys = [].tap do |keys|
      model = attributes[:model]
      if model.respond_to?(:original_filename)
        attributes[:model] = model.original_filename
      else
        keys << :model
      end

      test_data = attributes[:test_data]
      if test_data.respond_to?(:original_filename)
        attributes[:test_data] = test_data.original_filename
      elsif not (test_data.kind_of?(String) and test_data.match(URI::regexp(%w[http https])))
        keys << :test_data
      end
    end

    unless invalid_keys.empty?
      raise BadRequest.new(invalid_keys.map {|key| "invalid_param_#{key}" })
    end

    prediction = Prediction.new(attributes.merge(:state => 'processing'))
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
