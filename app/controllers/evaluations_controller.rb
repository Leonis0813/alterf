class EvaluationsController < ApplicationController
  def manage
    @evaluation = Evaluation.new
    @evaluations = Evaluation.all.order(:created_at => :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*evaluation_params)
    absent_keys = evaluation_params - attributes.symbolize_keys.keys
    raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

    model = attributes[:model]
    raise BadRequest.new('invalid_param_model') unless model.respond_to?(:original_filename)

    attributes[:model] = model.original_filename
    evaluation = Evaluation.new(attributes.merge(:state => 'processing'))
    if evaluation.save
      output_dir = "#{Rails.root}/tmp/files/#{evaluation.id}"
      FileUtils.mkdir_p(output_dir)
      File.open("#{output_dir}/#{model.original_filename}", 'w+b') do |f|
        f.write(model.read)
      end

      EvaluationJob.perform_later(evaluation.id)
      render :status => :ok, :json => {}
    else
      raise BadRequest.new(evaluation.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  private

  def evaluation_params
    %i[ model ]
  end
end