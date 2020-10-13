module Api
  module Analyses
    class ParametersController < ApplicationController
      before_action :check_request_analysis, only: %i[show]

      def show
        @parameter = request_analysis.parameter
        render status: :ok
      end

      private

      def check_request_analysis
        raise NotFound unless request_analysis
      end

      def request_analysis
        @request_analysis ||= Analysis.find_by(request.path_parameters.slice(:analysis_id))
      end
    end
  end
end
