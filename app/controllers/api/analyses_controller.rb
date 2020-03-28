module Api
  class AnalysesController < ApplicationController
    def index
      @analyses = Analysis.all.order(created_at: :desc).page(index_params[:page])
      render status: :ok, template: 'analyses/analyses'
    end

    private

    def index_params
      @index_params ||= request.query_parameters.slice(
        :page,
      )
    end
  end
end
