# frozen_string_literal: true
#
# Hyrax emits events during portions of a work's lifecycle using the `dry-events` gem.
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax's-Event-Bus-(Hyrax::Publisher)
# @see https://www.rubydoc.info/github/samvera/hyrax/Hyrax/Publisher
# @see https://github.com/samvera/hyrax/blob/hyrax-v3.5.0/lib/hyrax/publisher.rb
module Spot
  class ApplicationListener
    # Mint Handles for records when they are deposited
    def on_object_deposited(event)
      MintHandleJob.perform_later(event[:object])
    end
  end
end

Hyrax::Publisher.instance.subscribe(Spot::ApplicationListener.new)
