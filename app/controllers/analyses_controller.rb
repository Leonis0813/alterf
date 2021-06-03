class AnalysesController < ApplicationController
  before_action :check_request_analysis, only: %i[show download rebuild]

  def index
    check_schema(index_schema, index_params, 'analysis')

    @new_analysis = Analysis.new
    @new_analysis.build_parameter
    @index_form = Analyses::IndexForm.new(index_params.except(:page))
    @analyses = Analysis.where(@index_form.to_query)
                        .includes(:parameter)
                        .order(created_at: :desc)
                        .page(index_params[:page])
  end

  def execute
    check_schema(execute_schema, execute_params, 'analysis')
    check_invalid_file

    analysis = Analysis.new(execute_params.except(:data_file, :parameter))
    analysis.build_result
    analysis.build_parameter(execute_params[:parameter])

    unless analysis.save
      raise BadRequest, messages: analysis.errors.messages, resource: 'analysis'
    end

    if user_specified_data?
      file_path =
        Rails.root.join('tmp/files/analyses', analysis_id.to_s, 'race_list.txt')
      File.open(file_path, 'w') {|file| file.puts(race_ids.join("\n")) }
      analysis.update!(num_data: race_ids.size)
    end

    AnalysisJob.perform_later(analysis.id)
    render status: :ok, json: {}
  end

  def show
    @analysis = request_analysis
  end

  def download
    file_path =
      Rails.root.join('tmp/files/analyses', request_analysis.id.to_s, 'result.zip')
    raise NotFound unless File.exist?(file_path)

    stat = File.stat(file_path)
    send_file(file_path, filename: 'result.zip', length: stat.size)
  end

  def rebuild
    analysis = request_analysis.copy

    unless analysis.save
      raise BadRequest, messages: analysis.errors.messages, resource: 'analysis'
    end

    AnalysisJob.perform_later(analysis.id)
    render status: :ok, json: {}
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
    @index_params['parameter'] = parameter if parameter.present?
    @index_params = @index_params.with_indifferent_access
    @index_params
  end

  def execute_params
    return @execute_params if @execute_params

    @execute_params = request.request_parameters.slice(
      :data_source,
      :num_data,
      :data_file,
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
    @execute_params['parameter'] = parameter if parameter.present?
    @execute_params = @execute_params.with_indifferent_access
    @execute_params
  end

  def index_schema
    @index_schema ||= {
      type: :object,
      properties: {
        data_source: {type: :string, enum: Analysis::DATA_SOURCE_LIST},
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
      required: %i[data_source parameter],
      properties: {
        data_source: {type: :string, enum: Analysis::DATA_SOURCE_LIST},
        num_data: {type: :string, pattern: '^([1-9][0-9]*|\s*)$'},
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

  def check_invalid_file
    return unless user_specified_data?

    messages = {data_file: %w[invalid_parameter]}

    unless execute_params[:data_file].respond_to?(:read)
      raise BadRequest, messages: messages, resource: 'analysis'
    end

    if race_ids.empty? or race_ids.any?(&:empty?)
      raise BadRequest, messages: messages, resource: 'analysis'
    end

    return if race_ids.size == Denebola::Race.where(race_id: race_ids).count

    raise BadRequest, messages: messages, resource: 'analysis'
  end

  def user_specified_data?
    execute_params[:data_source] == Analysis::DATA_SOURCE_FILE
  end

  def race_ids
    @race_ids ||= execute_params[:data_file].read.lines.map(&:chomp)
  end
end
