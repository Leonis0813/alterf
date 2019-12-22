class EvaluationsController < ApplicationController
  def manage
    @evaluation = Evaluation.new
    @evaluations = Evaluation.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_absent_param(execute_param, %i[model data_source])
    check_invalid_param

    model = execute_param[:model]
    evaluation = Evaluation.new(
      evaluation_id: SecureRandom.hex,
      model: model.original_filename,
      data_source: execute_param[:data_source],
      num_data: num_data,
      state: 'processing',
    )
    unless evaluation.save
      error_codes = evaluation.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    output_dir = Rails.root.join('tmp', 'files', evaluation.id.to_s)
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir, model.original_filename), 'w+b') do |f|
      f.write(model.read)
    end

    if user_specified_data?
      file_path = File.join(output_dir, Settings.evaluation.race_list_filename)
      File.open(file_path, 'w') do |f|
        race_ids.each {|race_id| f.puts(race_id) }
      end
    end

    EvaluationJob.perform_later(evaluation.id)
    render status: :ok, json: {}
  end

  def show
    @evaluation = Evaluation.find_by(evaluation_id: params[:id])
    raise NotFound unless @evaluation
  end

  private

  def check_invalid_param
    model = execute_param[:model]
    raise BadRequest, 'invalid_param_model' unless model.respond_to?(:original_filename)

    return unless user_specified_data?

    raise BadRequest, 'invalid_param_data' if race_ids.empty?
    raise BadRequest, 'invalid_param_data' if race_ids.any?(&:empty?)
  end

  def user_specified_data?
    data_source = execute_param[:data_source]
    [Evaluation::DATA_SOURCE_FILE, Evaluation::DATA_SOURCE_TEXT].include?(data_source)
  end

  def num_data
    case execute_param[:data_source]
    when Evaluation::DATA_SOURCE_FILE, Evaluation::DATA_SOURCE_TEXT
      race_ids.size
    when Evaluation::DATA_SOURCE_RANDOM
      execute_param[:num_data]
    when Evaluation::DATA_SOURCE_REMOTE
      Evaluation::NUM_DATA_REMOTE
    end
  end

  def race_ids
    @race_ids ||= case execute_param[:data_source]
                  when 'file'
                    execute_param[:data].read.lines.map(&:chomp)
                  when 'text'
                    execute_param[:data].lines.map(&:chomp)
                  end
  end

  def execute_param
    @execute_param ||= request.request_parameters.slice(
      :model,
      :data_source,
      :num_data,
      :data,
    )
  end
end
