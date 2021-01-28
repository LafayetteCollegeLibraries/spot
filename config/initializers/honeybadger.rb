# frozen_string_literal: true
#
# Configuring Honeybadger to
Honeybadger.configure do |config|
  config.exceptions.ignore += [
    ActiveFedora::ObjectNotFoundError,
    Blacklight::Exceptions::RecordNotFound,
    ActionController::UnknownFormat
  ]

  config.before_notify do |notice|
    # Change "errors" to match your custom controller name.
    next if notice.component != "error"

    # wrapping this in a begin/rescue block bc sometimes the path isn't recognizable
    # (see ActionController::RoutingError)
    # Look up original route path and override controller/action in Honeybadger.
    params = Rails.application.routes.recognize_path(notice.url) rescue {} # rubocop:disable Style/RescueModifier
    notice.component = params.fetch(:controller, notice.component)
    notice.action = params.fetch(:action, notice.action)
  end
end
