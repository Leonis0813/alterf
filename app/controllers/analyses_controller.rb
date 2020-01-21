class AnalysesController < ApplicationController
  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_absent_param(execute_params, %i[num_data num_tree])

    analysis = Analysis.new(
      execute_params.merge(
        analysis_id: SecureRandom.hex,
        state: 'processing',
      ),
    )
    unless analysis.save
      error_codes = analysis.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    AnalysisJob.perform_later(analysis.id)
    render status: :ok, json: {}
  end

  private

  def execute_params
    @execute_params ||= request.request_parameters.slice(
      :num_data,
      :num_tree,
      :num_entry,
    )
  end
end
