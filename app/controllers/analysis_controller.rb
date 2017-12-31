# coding: utf-8
class AnalysisController < ApplicationController
  def manage
    @analysis = Analysis.new
  end

  def learn
    attributes = params.permit(*analysis_params)
    absent_keys = analysis_params - attributes.symbolize_keys.keys
    raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

    form = Analysis.new(attributes)
    if form.valid?
      AnalysisJob.perform_later(params[:num_data], params[:num_tree], params[:num_feature])
      render :status => :ok, :json => {}
    else
      raise BadRequest.new(form.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  private

  def analysis_params
    %i[ num_data num_tree num_feature ]
  end
end
