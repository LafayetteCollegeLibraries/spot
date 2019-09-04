# frozen_string_literal: true

# Mixin to add Handle identifier registration / updating
# after create/update tasks in a work's Actor.
#
# @example
#   module Hyrax
#     class WorkActor < Hyrax::Actors::BaseActor
#       include ::HandleIdentifiers
#     end
#   end
module HandleIdentifiers
  def create(env)
    super && enqueue_handle_job(env.curation_concern)
  end

  def update(env)
    super && enqueue_handle_job(env.curation_concern)
  end

  private

    # enqueues the MintHandleJob
    #
    # @param [ActiveFedora::Base] work
    # @return [void]
    def update_handle(work)
      MintHandleJob.perform_later(work)
    end
end
