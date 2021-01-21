# frozen_string_literal: true
#
# Configuring Honeybadger to
Honeybadger.configure do |config|
  config.before_notify do |notice|
    # Change "errors" to match your custom controller name.
    break if notice.component != "error"

    # Look up original route path and override controller/action in Honeybadger.
    params = Rails.application.routes.recognize_path(notice.url)
    notice.component = params[:controller]
    notice.action = params[:action]
  end
end
