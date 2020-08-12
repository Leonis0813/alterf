class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_schema(execute_schema, execute_params, 'prediction')
    check_invalid_file_params

    attribute = {model: execute_params[:model].original_filename}
    attribute[:test_data] = execute_params[:test_data]
    if attribute[:test_data].respond_to?(:original_filename)
      attribute[:test_data] = attribute[:test_data].original_filename
    end
    prediction = Prediction.new(attribute)
    unless prediction.save
      raise BadRequest, messages: prediction.errors.messages, resource: 'prediction'
    end

    save_files(prediction.id)
    PredictionJob.perform_later(prediction.id)
    render status: :ok, json: {}
  end

  private

  def execute_params
    @execute_params ||= request.request_parameters.slice(
      :model,
      :test_data,
    )
  end

  def execute_schema
    @execute_schema ||= {
      type: :object,
      required: %i[model test_data],
    }
  end

  def check_invalid_file_params
    invalid_keys = [].tap do |keys|
      keys << :model unless execute_params[:model].respond_to?(:original_filename)

      test_data = execute_params[:test_data]
      if test_data.is_a?(String) and not test_data.match?(URI.regexp(%w[http https]))
        keys << :test_data
      end
    end

    return if invalid_keys.empty?

    messages = invalid_keys.map {|key| [key, %w[invalid_parameter] }.to_h
    raise BadRequest, messages: messages, resource: 'prediction'
  end

  def save_files(prediction_id)
    execute_params.values.each do |value|
      next unless value.respond_to?(:original_filename)

      output_dir = Rails.root.join('tmp', 'files', 'predictions', prediction_id.to_s)
      FileUtils.mkdir_p(output_dir)
      File.open(File.join(output_dir, value.original_filename), 'w+b') do |f|
        f.write(value.read)
      end
    end
  end
end
