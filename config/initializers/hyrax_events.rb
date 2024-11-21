# frozen_string_literal: true
#
# Hyrax emits events during portions of a work's lifecycle using the `dry-events` gem.
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax's-Event-Bus-(Hyrax::Publisher)
# @see https://www.rubydoc.info/github/samvera/hyrax/Hyrax/Publisher
# @see https://github.com/samvera/hyrax/blob/hyrax-v3.5.0/lib/hyrax/publisher.rb
module Spot
  module Listeners
    class ApplicationListener
      # Mint Handles for records when they are deposited
      def on_object_deposited(event)
        MintHandleJob.perform_later(event[:object])
      end
    end
  end
end

Rails.application.config.to_prepare do
  Hyrax.publisher.subscribe(Spot::Listeners::ApplicationListener.new)
  Hyrax.publisher.subscribe(Spot::Listeners::ParentCollectionMembershipListener.new)
  Hyrax.publisher.subscribe(Spot::Listeners::SolrSuggestDictionariesListener.new)
end
