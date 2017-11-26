# coding: utf-8
class AnalysisController < ApplicationController
  def learn
    render :status => :ok, :json => {:message => '学習を開始しました', :param => request.request_parameters}
  end
end
