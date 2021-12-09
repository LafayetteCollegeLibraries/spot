# frozen_string_literal: true
#
# This may change in the future; it's definitely a first-pass at something new.
# We want to send a notification that a Fixity Check job has been run and provide
# the results. Eventually, this could/should be an email and/or an ActiveRecord
# item (see https://github.com/LafayetteCollegeLibraries/spot/issues/175).
module Spot
  class SendFixityStatusJob < ApplicationJob
    queue_as :low_priority

    # @param [Number] :item_count
    # @param [Number] :job_time
    # @return [void]
    def perform(item_count:, job_time:)
      return unless slack_ok?

      @item_count = item_count
      @job_time = job_time
      @errors = ChecksumAuditLog.latest_checks.where(passed: false).count

      send_message_to_slack
    end

    private

    # Are we able to send messages to slack?
    #
    # @return [true, false]
    def slack_ok?
      ENV['SLACK_API_TOKEN'] && ENV['SLACK_FIXITY_CHANNEL']
    end

    # @return [void]
    def send_message_to_slack
      slack_client.post('chat.postMessage',
                        channel: ENV.fetch('SLACK_FIXITY_CHANNEL'),
                        blocks: JSON.dump(slack_message),
                        as_user: true)
    end

    def fixity_host
      ENV.fetch('URL_HOST', "`#{`hostname`.chomp}`")
    end

    # The expected API format to create a 'block', rather than
    # a text, message to send to slack.
    #
    # @return [Hash]
    def slack_message
      [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: "Performed #{@item_count} fixity #{'check'.pluralize(@item_count)} " \
                  "in #{@job_time} seconds on #{fixity_host}"
          },
          fields: [
            { type: 'mrkdwn',     text: ':white_check_mark: *Successes*' },
            { type: 'mrkdwn',     text: ':warning: *Failures*' },
            { type: 'plain_text', text: (@item_count - @errors).to_s },
            { type: 'plain_text', text: @errors.to_s }
          ]
        }
      ]
    end

    # @return [Slack::Web::Client]
    def slack_client
      Slack::Web::Client.new
    end
  end
end
