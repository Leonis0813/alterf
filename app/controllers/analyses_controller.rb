class AnalysesController < ApplicationController
  before_action :check_request_analysis, only: %i[show download]

  def index
    @new_analysis = Analysis.new
    @new_analysis.build_parameter
    @analyses = Analysis.all
                        .includes(:parameter)
                        .order(created_at: :desc)
                        .page(params[:page])
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

  def download
    file_path =
      Rails.root.join('tmp', 'files', 'analyses', request_analysis.id.to_s, 'result.zip')
    raise NotFound unless File.exist?(file_path)

    stat = File.stat(file_path)
    send_file(file_path, filename: 'result.zip', length: stat.size)
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
    parameter = @execute_params['parameter']&.slice(
      'max_depth',
      'max_features',
      'max_leaf_nodes',
      'min_samples_leaf',
      'min_samples_split',
      'num_tree',
    )
    parameter ? @execute_params.merge!('parameter' => parameter) : @execute_params
  end

  def execute_schema
    @execute_schema ||= {
      type: :object,
      required: %i[num_data parameter],
      properties: {
        num_data: {type: :string, pattern: '^[1-9][0-9]*$'},
        num_entry: {type: :string, pattern: '^([1-9][0-9]*|\s*)$'},
        parameter: {
          type: :object,
          properties: {
            max_depth: {type: :string, pattern: '^([1-9][0-9]*|\s*)$'},
            max_features: {type: :string, enum: Analysis::Parameter::MAX_FEATURES_LIST},
            max_leaf_nodes: {type: :string, pattern: '^([1-9][0-9]*|\s*)$'},
            min_samples_leaf: {type: :string, pattern: '^([1-9][0-9]*|\s*)$'},
            min_samples_split: {type: :string, pattern: '^([1-9][0-9]*|\s*)$'},
            num_tree: {type: :string, pattern: '^([1-9][0-9]*|\s*)$'},
          },
        },
      },
    }
  end
end
