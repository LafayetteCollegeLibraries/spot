# frozen_string_literal: true
#
# Configuring Honeybadger to
Honeybadger.configure do |config|
  config.before_notify do |notice|
    # Change "errors" to match your custom controller name.
    next if notice.component != "error"

    # wrapping this in a begin/rescue block bc sometimes the path isn't recognizable
    # (see ActionController::RoutingError)
    begin
      # Look up original route path and override controller/action in Honeybadger.
      params = Rails.application.routes.recognize_path(notice.url)
      notice.component = params[:controller]
      notice.action = params[:action]
    rescue
      # do nothing, send the params we've attached
    end
  end
end
