# frozen_string_literal: true

# Mixin to add Handle identifier registration / updating
# after create/update tasks in a work's Actor.
#
# @example
#   module Hyrax
#     class WorkActor < Hyrax::Actors::BaseActor
#       include ::CreateHandleIdentifiers
#     end
#   end
module CreateHandleIdentifiers
  def create(env)
    super && MintHandleJob.perform_later(env.curation_concern)
  end
end
