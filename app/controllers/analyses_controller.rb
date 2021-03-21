class AnalysesController < ApplicationController
  before_action :check_request_analysis, only: %i[show download]

  def index
    check_schema(index_schema, index_params, 'analysis')

    @new_analysis = Analysis.new
    @new_analysis.build_parameter
    @index_form = Analysis::IndexForm.new(index_params.except(:page))
    @analyses = Analysis.where(@index_form.to_query)
                        .includes(:parameter)
                        .order(created_at: :desc)
                        .page(index_params[:page])
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

  def index_params
    return @index_params if @index_params

    @index_params = request.query_parameters.slice(:num_data, :page, :parameter)
    parameter = @index_params['parameter']&.slice(
      'max_depth',
      'max_features',
      'max_leaf_nodes',
      'min_samples_leaf',
      'min_samples_split',
      'num_tree',
    )
    @index_params.merge!('parameter' => parameter) if parameter.present?
    @index_params = @index_params.with_indifferent_access
    @index_params
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
    @execute_params.merge!('parameter' => parameter) if parameter.present?
    @execute_params = @execute_params.with_indifferent_access
    @execute_params
  end

  def index_schema
    @index_schema ||= {
      type: :object,
      properties: {
        num_data: {type: :string, pattern: '^[1-9][0-9]*$'},
        page: {type: :string, pattern: '^[1-9][0-9]*$'},
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
