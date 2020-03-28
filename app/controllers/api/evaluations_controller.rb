module Api
  class EvaluationsController < ApplicationController
    before_action :check_request_evaluation, only: %i[show]

    def show
      render status: :ok, template: 'evaluations/evaluation'
    end

    def index
      @evaluations = Evaluation.all.order(created_at: :desc).page(index_params[:page])
      render status: :ok, template: 'evaluations/evaluations'
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
