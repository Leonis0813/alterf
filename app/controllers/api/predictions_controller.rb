module Api
  class PredictionsController < ApplicationController
    def index
      @predictions = Prediction.all.order(created_at: :desc).page(index_params[:page])
      render status: :ok
    end

    private

    def index_params
      @index_params ||= request.query_parameters.slice(
        :page,
      )
    end
  end
end
