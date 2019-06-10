class EvaluationsController < ApplicationController
  def manage
    @evaluation = Evaluation.new
    @evaluations = Evaluation.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*evaluation_params)
    absent_keys = evaluation_params - attributes.symbolize_keys.keys
    unless absent_keys.empty?
      error_codes = absent_keys.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes
    end

    model = attributes[:model]
    raise BadRequest, 'invalid_param_model' unless model.respond_to?(:original_filename)

    attributes[:model] = model.original_filename
    evaluation = Evaluation.new(attributes.merge(state: 'processing'))
    unless evaluation.save
      error_codes = evaluation.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    output_dir = "#{Rails.root}/tmp/files/#{evaluation.id}"
    FileUtils.mkdir_p(output_dir)
    File.open("#{output_dir}/#{model.original_filename}", 'w+b') do |f|
      f.write(model.read)
    end

    EvaluationJob.perform_later(evaluation.id)
    render status: :ok, json: {}
  end

  def show
    @evaluation = Evaluation.find_by(evaluation_id: params[:id])
    raise NotFound unless @evaluation
  end

  private

  def evaluation_params
    %i[model]
  end
end
