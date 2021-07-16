class Evaluation::RacesController < EvaluationsController
  before_action :check_request_evaluation
  before_action :check_request_evaluation_race

  def show; end

  private

  def check_request_evaluation_race
    raise NotFound unless evaluation_race
  end

  def evaluation_race
    @evaluation_race ||= evaluation.races
                                   .find_by(request.path_parameters.slice(:race_id))
  end
end
