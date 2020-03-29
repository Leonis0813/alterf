module Api
  class EvaluationsController < ApplicationController
    before_action :check_request_evaluation, only: %i[show]

    def show
      render status: :ok
    end

    def index
      @evaluations = Evaluation.includes(data: :prediction_results).
                                all.order(created_at: :desc).page(index_params[:page])
      render status: :ok
    end

    private

    def check_request_evaluation
      raise NotFound unless evaluation
    end

    def evaluation
      @evaluation ||= Evaluation.find_by(request.path_parameters.slice(:evaluation_id))
    end

    def index_params
      @index_params ||= request.query_parameters.slice(
        :page,
      )
    end
  end
end
