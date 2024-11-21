# frozen_string_literal: true
#
# Hyrax emits events during portions of a work's lifecycle using the `dry-events` gem.
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax's-Event-Bus-(Hyrax::Publisher)
# @see https://www.rubydoc.info/github/samvera/hyrax/Hyrax/Publisher
# @see https://github.com/samvera/hyrax/blob/hyrax-v3.5.0/lib/hyrax/publisher.rb
Rails.application.config.to_prepare do
  Hyrax.publisher.subscribe(Spot::Listeners::MintHandleListener.new)
  Hyrax.publisher.subscribe(Spot::Listeners::ParentCollectionMembershipListener.new)
  Hyrax.publisher.subscribe(Spot::Listeners::SolrSuggestDictionariesListener.new)
end
