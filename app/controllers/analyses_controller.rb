class AnalysesController < ApplicationController
  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*analysis_params)
    absent_keys = analysis_params - attributes.symbolize_keys.keys
    raise BadRequest, absent_keys.map {|key| "absent_param_#{key}" } unless absent_keys.empty?

    analysis = Analysis.new(attributes.merge(state: 'processing'))
    raise BadRequest, analysis.errors.messages.keys.map {|key| "invalid_param_#{key}" } unless analysis.save

    AnalysisJob.perform_later(analysis.id)
    render status: :ok, json: {}
  end

  private

  def analysis_params
    %i[num_data num_tree]
  end
end
