# coding: utf-8
class AnalysisController < ApplicationController
  def learn
    AnalysisJob.perform_later(params[:num_data], params[:num_tree], params[:num_feature])
  end
end
