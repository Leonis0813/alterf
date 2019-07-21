class EvaluationsController < ApplicationController
  def manage
    @evaluation = Evaluation.new
    @evaluations = Evaluation.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_absent_param(%i[model data_source])

    model = evaluation_param[:model]
    raise BadRequest, 'invalid_param_model' unless model.respond_to?(:original_filename)

    evaluation = Evaluation.new(
      evaluation_id: SecureRandom.hex,
      model: model.original_filename,
      data_source: evaluation_param[:data_source],
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

    if %w[file text].include?(evaluation.data_source)
      race_ids = case evaluation.data_source
                 when 'file'
                   evaluation_param[:data].read.lines.map(&:chomp)
                 when 'text'
                   evaluation_param[:data].lines.map(&:chomp)
                 end

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

  def check_absent_param(required_keys)
    absent_keys = required_keys - evaluation_param.symbolize_keys.keys
    return if absent_keys.empty?

    error_codes = absent_keys.map {|key| "absent_param_#{key}" }
    raise BadRequest, error_codes
  end

  def evaluation_param
    @evaluation_param ||= params.permit(:model, :data_source, :data)
  end
end
