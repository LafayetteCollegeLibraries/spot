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

    # Bypasses CAS authentication (development only)
    #
    # @return [void]
    def log_in_as_dev_user!
      return unless Rails.env.development? && (current_user || ENV.key?('DEV_USER'))
      user = User.find_by(email: ENV['DEV_USER'])
      sign_in(user) unless user.nil?
    end
end
