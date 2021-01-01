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
      parameter = case error[:failed_attribute]
                  when 'Required'
                    error[:message].scan(/required property of '(.*)'/).first.first
                  else
                    error[:fragment].split('/').last
                  end

      error_code = case error[:failed_attribute]
                   when 'Required'
                     'absent_parameter'
                   else
                     'invalid_parameter'
                   end

      [parameter, [error_code]]
    end.to_h

    raise BadRequest, messages: messages, resource: resource
  end

  def remove_old_files
    Analysis.where('performed_at <= ?', 3.days.ago).pluck(:id).each do |id|
      result_file = Rails.root.join('tmp', 'files', 'analyses', id.to_s)
      next unless File.exist?(result_file)

      FileUtils.rm_rf(result_file)
    end

    Evaluation.where('performed_at <= ?', 1.month.ago).pluck(:id).each do |id|
      data_file = Rails.root.join('tmp', 'files', 'evaluations', id.to_s)
      next unless File.exist?(data_file)

      FileUtils.rm_rf(data_file)
    end
  end
end
