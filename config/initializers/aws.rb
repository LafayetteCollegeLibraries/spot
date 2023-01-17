# frozen_string_literal: true
Aws.config.update(endpoint: ENV['AWS_ENDPOINT_URL']) if ENV['AWS_ENDPOINT_URL'].present?
Aws.config.update(force_path_style: true) unless Rails.env.production?
