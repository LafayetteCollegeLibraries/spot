# frozen_string_literal: true
Slack.configure { |config| config.token = ENV['SLACK_API_TOKEN'] } if ENV['SLACK_API_TOKEN']
