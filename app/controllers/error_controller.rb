# frozen_string_literal: true
class ErrorController < ApplicationController
  before_action :set_status

  respond_to :html

  def show
    render @status.to_s, status: @status.to_i
  rescue
    # fallback for statuses that we haven't created a view for
    render '500', status: 500
  end

  private

    def set_status
      backtrace_cleaner = request.env['action_dispatch.backtrace_cleaner']
      raw_exception = request.env['action_dispatch.exception']
      @exception = ActionDispatch::ExceptionWrapper.new(backtrace_cleaner, raw_exception)
      @status = @exception.status_code

      # hyrax's dashboard_helper_behavior is expecting this to be defined from a route
      params[:controller] = self.class.name.to_s
    end
end
