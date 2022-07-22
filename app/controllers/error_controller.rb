# frozen_string_literal: true
class ErrorController < ApplicationController
  before_action :set_status

  respond_to :html

  def show
    respond_to do |format|
      format.html { render @status.to_s, status: @status.to_i }
      format.json { render json: json_response, status: @status.to_i }
      format.text { render plain: plain_text_response, status: @status.to_i }
    end
  rescue
    send_honeybadger_notification!

    # fallback for statuses that we haven't created a view for
    render '500', status: :internal_server_error
  end

  private

  def json_response
    %({"error": true, "status": #{@status.to_i}, "message": "#{status_message}"})
  end

  def plain_text_response
    "#{@status} #{status_message}"
  end

  def status_message
    Rack::Utils::HTTP_STATUS_CODES.fetch(@status, '')
  end

  def send_honeybadger_notification!
    Honeybadger.notify(
      'An error occurred causing a 500 page to render',
      backtrace: @exception.full_trace,
      controller: self.class.name.to_s,
      action: action_name,
      parameters: params
    )
  end

  def set_status
    backtrace_cleaner = request.env['action_dispatch.backtrace_cleaner']
    raw_exception = request.env['action_dispatch.exception']
    @exception = ActionDispatch::ExceptionWrapper.new(backtrace_cleaner, raw_exception)
    @status = @exception.status_code

    # hyrax's dashboard_helper_behavior is expecting this to be defined from a route
    params[:controller] = self.class.name.to_s
  end
end
