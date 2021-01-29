# frozen_string_literal: true
class ErrorController < ApplicationController
  # need to update the request's formats _before_ the #show method. this will prevent
  # 'missing template' errors for stuff like '.pdf', etc.
  before_action :ensure_response_can_be_served!

  helper_method :error_t, :error_banner_image

  # in order to write a minimal controller action, rails wants an instance variable @error
  # to be defined. instead of making a model for this, we'll just use a struct wrapper.
  ErrorWrapper = Struct.new(:request) do
    # the raw exception from the env
    def exception
      request.env['action_dispatch.exception']
    end

    # The status code for the exception
    #
    # @return [Number]
    def status
      @status ||= ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
    end

    # Text for the status code
    #
    # @return [String, nil]
    def status_text
      Rack::Utils::HTTP_STATUS_CODES.fetch(status, nil)
    end

    # If we've rescued this exception, get the symbol assigned to it to
    # help determine the locale key.
    #
    # @return [Symbol]
    def response_key
      ActionDispatch::ExceptionWrapper.rescue_responses[exception.class.name]
    end
  end

  def show
    @error = ErrorWrapper.new(request)
    response.status = @error.status
  end

  private

    # @return [String]
    def error_banner_image
      found_asset = Rails.application.assets.find_asset("#{@error.status}-splash.jpg")
      return "#{@error.status}-splash.jpg" unless found_asset.nil?

      '500-splash.jpg'
    end

    # Helper method to ensure the error messaging is scope properly (without having to write
    # this out each time)
    #
    # @param [String] key
    # @param [Hash] **kwargs args to pass to I18n.t
    # @return [String]
    def error_t(key, **kwargs)
      I18n.t("#{@error.response_key}.#{key}",
             scope: ['spot', 'error'],
             default: [@error.status_text, "internal_server_error.#{key}"],
             **kwargs)
    end

    # Restrict the response to html if the format isn't one we're prepared to serve a response to
    # (aka '.pdf', '.jpg', etc).
    #
    # @return [void]
    def ensure_response_can_be_served!
      return if %i[html json text].include?(request.format.to_sym)

      request.formats = [:html]
    end

    # Not nearly as accurate as a third-party gem, but this should at least cut back on
    # the number of errors that get sent to Honeybadger.
    #
    # @return [true, false]
    # @see https://github.com/projectblacklight/blacklight/blob/v6.23.0/lib/blacklight/configuration.rb#L144
    def request_is_a_bot?
      req.env['HTTP_USER_AGENT'] =~ /bot/
    end
end
