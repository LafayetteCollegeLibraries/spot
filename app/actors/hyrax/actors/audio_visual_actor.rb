# frozen_string_literal: true
module Hyrax
  module Actors
    class AudioVisualActor < ::Spot::Actors::BaseActor
      def create(env)
        super(env) && ::Spot::ImportOembedThumbnailJob.perform_later(work: env.curation_concern, user_id: env.current_ability.current_user.id)
      end
    end
  end
end
