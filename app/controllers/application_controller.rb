class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :remove_old_files

  rescue_from BadRequest do |e|
    render status: :bad_request, json: {'errors' => e.errors}
  end

  rescue_from NotFound do
    head :not_found
  end

  def check_schema(schema, request_parameter, resource)
    errors = JSON::Validator.fully_validate(
      schema,
      request_parameter,
      errors_as_objects: true,
    )
    return if errors.empty?

    messages = errors.map do |error|
      [error[:fragment].split('/').second, %w[invalid_parameter]]
    end.to_h

    raise BadRequest, messages: messages, resource: resource
  end

  def remove_old_files
    Evaluation.where('performed_at <= ?', 1.month.ago).pluck(:id).each do |id|
      data_file = Rails.root.join('tmp', 'files', 'evaluations', id.to_s)
      next unless File.exist?(data_file)

      FileUtils.rm_rf(data_file)
    end
  end
end
