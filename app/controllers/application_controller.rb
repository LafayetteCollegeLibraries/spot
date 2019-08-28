# frozen_string_literal: true
class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController

  layout 'hyrax'

  before_action :log_in_as_dev_user!

  # from Blacklight: 'Discarding flash messages on XHR requests is deprecated.'
  skip_after_action :discard_flash_if_xhr

  protect_from_forgery with: :exception

  private

    # Modified from its source in +Hyrax::Controller+ in that we're
    # _not_ passing the exception message in the +redirect_to+ call.
    # What was happening was users were being redirected to the log-in
    # screen and after they logged in (and were able to view the item)
    # they were still presented with a "You are not authorized to access this item"
    # flash warning.
    #
    # If I'm not mistaken, if the user is not authorized to view the
    # item after signing-in, the permissions check will be re-run
    # for the user and the +#deny_access_for_current_user+ method
    # will be called.
    #
    # @see https://github.com/samvera/hyrax/blob/v2.5.1/app/controllers/concerns/hyrax/controller.rb#L75-L81
    def deny_access_for_anonymous_user(exception, json_message)
      session['user_return_to'] = request.url
      respond_to do |wants|
        wants.html { redirect_to main_app.new_user_session_path }
        wants.json { render_json_response(response_type: :unauthorized, message: json_message) }
      end
    end

    # Bypasses CAS authentication (development only)
    # :nocov:
    #
    # @return [void]
    def log_in_as_dev_user!
      return unless Rails.env.development? && (current_user || ENV.key?('DEV_USER'))
      user = User.find_by(email: ENV['DEV_USER'])
      sign_in(user) unless user.nil?
    end
end
