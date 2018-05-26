class AnalysesController < ApplicationController
  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(:created_at => :desc)
  end

  def execute
    attributes = params.permit(*analysis_params)
    absent_keys = analysis_params - attributes.symbolize_keys.keys
    raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

    analysis = Analysis.new(attributes.merge('state' => 'processing'))
    if analysis.save
      AnalysisJob.perform_later(analysis.id)
      render :status => :ok, :json => {}
    else
      raise BadRequest.new(analysis.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  private

  def analysis_params
    %i[ num_data num_tree num_feature ]
  end
end
