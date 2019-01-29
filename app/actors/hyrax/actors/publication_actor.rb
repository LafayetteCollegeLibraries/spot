# frozen_string_literal: true
module Hyrax
  module Actors
    class PublicationActor < Hyrax::Actors::BaseActor
      include ::DeserializesRdfLiterals

      private

        # Overrides the BaseActor method to allow us to stuff in
        # `date_uploaded` values where necessary.
        #
        # @return [void]
        def apply_deposit_date(env)
          env.curation_concern.date_uploaded = get_date_uploaded_value(env)
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
