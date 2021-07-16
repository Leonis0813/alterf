class Api::Analyses::Result::ImportancesController < Api::Analyses::ResultController
  before_action :check_request_analysis
  before_action :check_request_analysis_result

  def index
    @importances = analysis_result.importances
    render status: :ok
  end
end
