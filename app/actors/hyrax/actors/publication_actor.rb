# frozen_string_literal: true
module Hyrax
  module Actors
    class PublicationActor < ::Spot::BaseActor
      private

        # Overrides the +Hyrax::Actors::BaseActor+ method so that we can apply a +date_available+
        # value to the item.
        #
        # @param [Hyrax::Actors::Environment] env
        # @return [void]
        # @see {#apply_date_available}
        def apply_save_data_to_curation_concern(env)
          super

          apply_date_available(env)
        end

        # Allows us to apply a +date_available+ value to a work. The property
        # is similar to +date_uploaded+, but accounts for embargoes where present.
        # As the method calling this ({#apply_save_data_to_curation_concern}) is
        # run on both +#create+ and +#update+, we'll skip this if the value has
        # already been provided.
        #
        # @param [Hyrax::Actors::Environment] env
        # @return [void]
        def apply_date_available(env)
          return unless env.curation_concern.date_available.empty?

          embargo = env.curation_concern.embargo
          env.curation_concern.date_available =
            if embargo.present?
              [embargo.embargo_release_date.strftime('%Y-%m-%d')]
            else
              [Time.zone.now.strftime('%Y-%m-%d')]
            end
        end
    end
  end
end
