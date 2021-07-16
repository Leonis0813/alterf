class Api::AnalysesController < ApplicationController
  before_action :check_request_analysis, only: %i[show]

  def show
    render status: :ok
  end

  private

  def check_request_analysis
    raise NotFound unless analysis
  end

  def analysis
    @analysis ||= Analysis.find_by(request.path_parameters.slice(:analysis_id))
  end
end
