# frozen_string_literal: true
#
# Using Hyrax's callback system for performing tasks after certain events
# (ex. minting a Handle identifier after a work's creation). Because Hyrax's
# registry only allows one block per hook (see: https://github.com/samvera/hyrax/blob/v2.9.6/lib/hyrax/callbacks/registry.rb#L25-L29),
# we need to ensure that the blocks registered by Hyrax on initialization are
# retained.
#
# @see https://github.com/samvera/hyrax/blob/v2.9.6/config/initializers/hyrax_callbacks.rb
#
# On top of this, the callback registry is being deprecated in Hyrax v3
# (and removed by v4) in favor of an event bus system. So when the time comes,
# we'll need to replace these callbacks with registered events. However,
# this new interface allows for multiple listeners on an event, which should
# help prevent the need to know what Hyrax is doing during an event.
#
# @todo replace callbacks with Hyrax's Event Bus after upgrading to Hyrax v3
# @see https://github.com/samvera/hyrax/wiki/Hyrax's-Event-Bus-(Hyrax::Publisher)#replacing-hyraxcallbacks
# @see https://github.com/samvera/hyrax/blob/v3.3.0/lib/hyrax/publisher.rb

# Mint Handle identifiers after a work is created. The `:after_create_concern`
# is called as part of `Hyrax::Actors::BaseActor#create` method
#
# @see https://github.com/samvera/hyrax/blob/v2.9.6/app/actors/hyrax/actors/base_actor.rb#L18-L22
Hyrax.config.callback.set(:after_create_concern) do |curation_concern, user|
  ContentDepositEventJob.perform_later(curation_concern, user)
  MintHandleJob.perform_later(curation_concern)
end
