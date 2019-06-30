class AnalysesController < ApplicationController
  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*analysis_params)
    check_absent_params(attributes, analysis_params)

    analysis = Analysis.new(attributes.merge(state: 'processing'))
    unless analysis.save
      error_codes = analysis.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    AnalysisJob.perform_later(analysis.id)
    render status: :ok, json: {}
  end

  private

  def analysis_params
    %i[num_data num_tree]
  end
end
