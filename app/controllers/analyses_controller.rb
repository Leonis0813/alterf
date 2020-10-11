class AnalysesController < ApplicationController
  before_action :check_request_analysis, only: %i[show]

  def manage
    @analysis = Analysis.new
    @analysis.build_parameter
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_schema(execute_schema, execute_params, 'analysis')

    analysis = Analysis.new(execute_params.except(:parameter))
    analysis.build_result
    analysis.build_parameter(execute_params[:parameter])
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
    return @execute_params if @execute_params

    @execute_params = request.request_parameters.slice(
      :num_data,
      :num_entry,
      :parameter,
    )
    @execute_params[:parameter]&.slice!(
      :max_depth,
      :max_features,
      :max_leaf_nodes,
      :min_samples_leaf,
      :min_samples_split,
      :num_tree,
    )
  end

  def execute_schema
    @execute_schema ||= {
      type: :object,
      required: %i[num_data parameter],
      properties: {
        num_data: {type: :string, pattern: '^[1-9][0-9]*$'},
        num_entry: {type: :string, pattern: '^[1-9][0-9]*$'},
        parameter: {
          type: :object,
          properties: {
            max_depth: {type: :string, pattern: '^[1-9][0-9]*$'},
            max_features: {type: :string, enum: Analysis::Parameter::MAX_FEATURES_LIST},
            max_leaf_nodes: {type: :string, pattern: '^[1-9][0-9]*$'},
            min_samples_leaf: {type: :string, pattern: '^[1-9][0-9]*$'},
            min_samples_split: {type: :string, pattern: '^[1-9][0-9]*$'},
            num_tree: {type: :string, pattern: '^[1-9][0-9]*$'},
          },
        },
      },
    }
  end
end
