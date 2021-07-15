class Api::Analyses::Result::DecisionTreesController < Api::Analyses::ResultController
  before_action :check_request_analysis
  before_action :check_request_analysis_result
  before_action :check_request_analysis_result_decision_tree

  def show
    render status: :ok
  end

  private

  def check_analysis_result_decision_tree
    raise NotFound unless decision_tree
  end

  def decision_tree
    @decision_tree ||=
      analysis_result.decision_trees
                     .find_by(request.path_parameters.slice(:decision_tree_id))
  end
end
