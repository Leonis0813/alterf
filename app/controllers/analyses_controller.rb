class AnalysesController < ApplicationController
  before_action :check_request_analysis, only: %i[show]

  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_schema(execute_schema, execute_params, resource: 'payment')

    analysis = Analysis.new(execute_params)
    analysis.build_result
    unless analysis.save
      raise BadRequest, messages: analysis.errors.messages, resource: 'analysis'
    end

    AnalysisJob.perform_later(analysis.id)
    render status: :ok, json: {}
  end

  def show
    @analysis = request_analysis
  end

  private

  def check_request_analysis
    raise NotFound unless request_analysis
  end

  def request_analysis
    @request_analysis ||= Analysis.find_by(request.path_parameters.slice(:analysis_id))
  end

  def execute_params
    @execute_params ||= request.request_parameters.slice(
      :num_data,
      :num_tree,
      :num_entry,
    )
  end

  def execute_schema
    @execute_schema ||= {
      type: :object,
      required: %i[num_data num_tree],
      properties: {
        num_data: {type: :string, pattern: '^[1-9][0-9]*$'},
        num_tree: {type: :string, pattern: '^[1-9][0-9]*$'},
        num_entry: {type: :string, pattern: '^[1-9][0-9]*$'},
      },
    }
  end
end
