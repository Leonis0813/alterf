class EvaluationsController < ApplicationController
  before_action :check_request_evaluation, only: %i[show download]

  def manage
    @evaluation = Evaluation.new
    @evaluations = Evaluation.includes(data: :prediction_results)
                             .all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_schema(execute_schema, execute_params, 'evaluation')
    check_invalid_param

    model = execute_params[:model]
    evaluation = Evaluation.new(
      model: model.original_filename,
      data_source: execute_params[:data_source],
      num_data: num_data,
    )
    unless evaluation.save
      raise BadRequest, messages: evaluation.errors.messages, resource: 'evaluation'
    end

    output_dir = Rails.root.join('tmp', 'files', 'evaluations', evaluation.id.to_s)
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
  end

  def download
    file_path =
      Rails.root.join('tmp', 'files', 'evaluations', evaluation.id.to_s, 'data.txt')
    raise NotFound unless File.exist?(file_path)

    stat = File.stat(file_path)
    send_file(file_path, filename: 'data.txt', length: stat.size)
  end

  private

  def check_request_evaluation
    raise NotFound unless evaluation
  end

  def evaluation
    @evaluation ||= Evaluation.includes(data: :prediction_results)
                              .find_by(request.path_parameters.slice(:evaluation_id))
  end

  def check_invalid_param
    unless execute_params[:model].respond_to?(:original_filename)
      raise BadRequest, messages: {model: %w[invalid_parameter]}, resource: 'evaluation'
    end

    return unless user_specified_data?
    return unless race_ids.empty? or race_ids.any?(&:empty?)

    raise BadRequest, messages: {data: %w[invalid_parameter]}, resource: 'evaluation'
  end

  def user_specified_data?
    data_source = execute_params[:data_source]
    [Evaluation::DATA_SOURCE_FILE, Evaluation::DATA_SOURCE_TEXT].include?(data_source)
  end

  def num_data
    case execute_params[:data_source]
    when Evaluation::DATA_SOURCE_FILE, Evaluation::DATA_SOURCE_TEXT
      race_ids.size
    when Evaluation::DATA_SOURCE_RANDOM
      execute_params[:num_data]
    when Evaluation::DATA_SOURCE_REMOTE
      Evaluation::NUM_DATA_REMOTE
    end
  end

  def race_ids
    @race_ids ||= case execute_params[:data_source]
                  when Evaluation::DATA_SOURCE_FILE
                    execute_params[:data].read.lines.map(&:chomp)
                  when Evaluation::DATA_SOURCE_TEXT
                    execute_params[:data].lines.map(&:chomp)
                  end
  end

  def execute_params
    @execute_params ||= request.request_parameters.slice(
      :model,
      :data_source,
      :num_data,
      :data,
    )
  end

  def execute_schema
    @execute_schema ||= {
      type: :object,
      required: %i[model data_source],
      properties: {
        data_source: {type: :string, enum: Evaluation::DATA_SOURCE_LIST},
        num_data: {type: :string, pattern: '^[1-9][0-9]*$'},
      },
    }
  end
end
