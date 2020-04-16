# frozen_string_literal: true
class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController

  with_themed_layout '1_column'

  before_action :store_user_location!, if: :storable_location?
  before_action :log_in_as_dev_user!

  # from Blacklight: 'Discarding flash messages on XHR requests is deprecated.'
  skip_after_action :discard_flash_if_xhr

  protect_from_forgery with: :exception

  # @return [Hash]
  # @todo remove this when supporting multiple locales
  def default_url_options
    super.reject { |k, _v| k == :locale }
  end

  # Borrowed from pul's figgy app. Restricts our guests to a single entry
  # in the database, preventing hundreds of fake user accounts from being
  # generated.
  #
  # @see https://github.com/pulibrary/figgy/blob/801141d/app/controllers/application_controller.rb#L31-L35
  # @return [User]
  def guest_user
    @guest_user ||= User.where(guest: true).first || super
  end

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
    def deny_access_for_anonymous_user(_exception, json_message)
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

    # Borrowed from the Devise wiki:
    #
    # > Its important that the location is NOT stored if:
    # > - The request method is not GET (non idempotent)
    # > - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
    # >    infinite redirect loop.
    # > - The request is an Ajax request as this can lead to very unexpected behaviour.
    #
    # Also adds a check to ignore download paths (iframe requests made by an item
    # viewer will take precedence over the user's last visited path).
    def storable_location?
      return false if request.path.start_with?('/downloads') || request.path.end_with?('/manifest')
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
    end

    def store_user_location!
      # :user is the scope we are authenticating
      store_location_for(:user, request.fullpath)
    end

    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || super
    end
end
