# frozen_string_literal: true
module Hyrax
  module Actors
    class PublicationActor < Hyrax::Actors::BaseActor
      include ::DeserializesRdfLiterals

      private

        # Overrides the BaseActor method to allow us to stuff in
        # `date_uploaded` values where necessary.
        #
        # @param [Hyrax::Actors::Environment] env
        # @return [void]
        def apply_deposit_date(env)
          env.curation_concern.date_uploaded = get_date_uploaded_value(env)
        end

        # Overrides the BaseActor method so that we can apply a +date_available+
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

        # @param [Hyrax::Actors::Environment] env
        # @return [DateTime]
        def get_date_uploaded_value(env)
          concern = env.curation_concern

          if env.attributes[:date_uploaded].present?
            DateTime.parse(env.attributes[:date_uploaded]).utc
          elsif concern.date_uploaded.present?
            # since this is only being called on `#create`, the concern
            # shouldn't necessarily have a date_uploaded set already.
            # but, in the event that it is, we should retain the value
            # as a UTC DateTime.
            DateTime.parse(concern.date_uploaded.to_s).utc
          else
            # this is what `BaseActor#apply_deposit_date` does, so we'll
            # keep that as our fallback.
            TimeService.time_in_utc
          end
        end
    end
  end
end
