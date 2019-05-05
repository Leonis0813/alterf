class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*prediction_params)
    absent_keys = prediction_params - attributes.symbolize_keys.keys
    unless absent_keys.empty?
      error_codes = absent_keys.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes
    end

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
      elsif not (test_data.is_a?(String) and test_data.match(URI.regexp(%w[http https])))
        keys << :test_data
      end
    end

    unless invalid_keys.empty?
      error_codes = invalid_keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    prediction = Prediction.new(attributes.merge(state: 'processing'))
    unless prediction.save
      error_codes = prediction.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    params.slice(*prediction_params).values.each do |value|
      next unless value.respond_to?(:original_filename)

      output_dir = "#{Rails.root}/tmp/files/#{prediction.id}"
      FileUtils.mkdir_p(output_dir)
      File.open("#{output_dir}/#{value.original_filename}", 'w+b') do |f|
        f.write(value.read)
      end
    end

    PredictionJob.perform_later(prediction.id)
    render status: :ok, json: {}
  end

  private

  def prediction_params
    %i[model test_data]
  end
end
