class AnalysesController < ApplicationController
  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attribute = params.permit(*analysis_param_keys)
    check_absent_param(attribute, analysis_param_keys)

    analysis = Analysis.new(attribute.merge(state: 'processing'))
    unless analysis.save
      error_codes = analysis.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    AnalysisJob.perform_later(analysis.id)
    render status: :ok, json: {}
  end

  private

  def analysis_param_keys
    %i[num_data num_tree]
  end
end
