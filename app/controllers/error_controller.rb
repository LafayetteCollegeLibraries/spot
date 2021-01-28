# frozen_string_literal: true
class ErrorController < ApplicationController
  respond_to :html, :json, :text

  helper_method :error_t

  # The idea here is that we'll try to render the error page via a partial, but if that
  # partial doesn't exist (ex. we've received an error we haven't anticipated) we'll
  # send the error to honeybadger and render the generic 500 error page.
  #
  # rubocop:disable Lint/HandleExceptions
  def show
    @exception = request.env['action_dispatch.exception']
    @status = ActionDispatch::ExceptionWrapper.new(request.env, @exception).status_code
    @status_text = Rack::Utils::HTTP_STATUS_CODES.fetch(@status, nil)
    @response_key = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]

    response.status = @status

    send_honeybadger_notification! if @status == 500
  end

  private
    def send_honeybadger_notification!
      Honeybadger.notify(@exception, action: action_name, parameters: params)
    end

    # @return [String]
    def banner_image
      found_asset = Rails.application.assets.find_asset("#{@status}-splash.jpg")
      return "#{@status}-splash.jpg" unless found_asset.nil?

      '500-splash.jpg'
    end

    def error_t(key)
      I18n.t("#{@response_key}.#{key}", scope: ['spot', 'error'], default: [@status_text, "internal_server_error.#{key}"])
    end
end
