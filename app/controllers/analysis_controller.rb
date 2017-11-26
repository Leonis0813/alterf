# coding: utf-8
class AnalysisController < ApplicationController
  def learn
    ret = system "Rscript #{Rails.root}/scripts/analyze/learn.r #{params[:num_data]} #{params[:num_tree]} #{params[:num_feature]}"
    if ret
      render :status => :ok, :json => {}
    else
      render :status => :bad_request, :json => {}
    end
  end
end
