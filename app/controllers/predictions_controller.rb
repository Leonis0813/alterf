class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attribute = params.permit(*prediction_param_keys)
    check_absent_param(attribute, prediction_param_keys)
    check_invalid_file_params(attribute)

    attribute[:model] = attribute[:model].original_filename
    if attribute[:test_data].respond_to?(:original_filename)
      attribute[:test_data] = attribute[:test_data].original_filename
    end
    prediction = Prediction.new(attribute.merge(state: 'processing'))
    unless prediction.save
      error_codes = prediction.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    save_files(prediction.id)
    PredictionJob.perform_later(prediction.id)
    render status: :ok, json: {}
  end

  private

  def prediction_param_keys
    %i[model test_data]
  end

  def check_invalid_file_params(attribute)
    invalid_keys = [].tap do |keys|
      keys << :model unless attribute[:model].respond_to?(:original_filename)

      test_data = attribute[:test_data]
      if test_data.is_a?(String) and not test_data.match(URI.regexp(%w[http https]))
        keys << :test_data
      end
    end

    return if invalid_keys.empty?

    error_codes = invalid_keys.map {|key| "invalid_param_#{key}" }
    raise BadRequest, error_codes
  end

  def save_files(prediction_id)
    params.slice(*prediction_param_keys).values.each do |value|
      next unless value.respond_to?(:original_filename)

      output_dir = "#{Rails.root}/tmp/files/#{prediction_id}"
      FileUtils.mkdir_p(output_dir)
      File.open("#{output_dir}/#{value.original_filename}", 'w+b') do |f|
        f.write(value.read)
      end
    end
  end
end
