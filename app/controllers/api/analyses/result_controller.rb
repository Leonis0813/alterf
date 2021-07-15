class Api::Analyses::ResultController < Api::AnalysesController
  def check_request_analysis_result
    raise NotFound unless analysis_result
  end

  def analysis_result
    @analysis_result ||= analysis.result
  end
end
