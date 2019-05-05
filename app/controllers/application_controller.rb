class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from BadRequest do |e|
    render status: :bad_request, json: e.errors
  end

  rescue_from NotFound do
    head :not_found
  end

  def check_absent_param(required_params)
    request_params = params.permit(*required_params)
    absent_keys = required_params - request_params.symbolize_keys.keys
    unless absent_keys.empty?
      error_codes = absent_keys.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes
    end
  end
end
