class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*prediction_params)
    check_absent_params(attributes, prediction_params)
    check_invalid_file_params(attributes)

    attributes[:model] = attributes[:model].original_filename
    if attributes[:test_data].respond_to?(:original_filename)
      attributes[:test_data] = attributes[:test_data].original_filename
    end
    prediction = Prediction.new(attributes.merge(state: 'processing'))
    unless prediction.save
      error_codes = prediction.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    save_files
    PredictionJob.perform_later(prediction.id)
    render status: :ok, json: {}
  end

  private

  def prediction_params
    %i[model test_data]
  end

  def check_invalid_file_params(attributes)
    invalid_keys = [].tap do |keys|
      keys << :model unless attributes[:model].respond_to?(:original_filename)

      test_data = attributes[:test_data]
      if test_data.is_a?(String) and not test_data.match(URI.regexp(%w[http https]))
        keys << :test_data
      end
    end

    unless invalid_keys.empty?
      error_codes = invalid_keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end
  end

  def save_files
    params.slice(*prediction_params).values.each do |value|
      next unless value.respond_to?(:original_filename)

      output_dir = "#{Rails.root}/tmp/files/#{prediction.id}"
      FileUtils.mkdir_p(output_dir)
      File.open("#{output_dir}/#{value.original_filename}", 'w+b') do |f|
        f.write(value.read)
      end
    end
  end
end
