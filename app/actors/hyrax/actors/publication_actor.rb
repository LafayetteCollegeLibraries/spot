# frozen_string_literal: true
module Hyrax
  module Actors
    class PublicationActor < Hyrax::Actors::BaseActor
      private

        # Overrides the BaseActor method to allow us to stuff in
        # `date_uploaded` values where necessary.
        #
        # @return [void]
        def apply_deposit_date(env)
          return super unless date_uploaded_present?(env)
          env.curation_concern.date_uploaded = get_date_uploaded_value(env)
        end

        # @param [Hyrax::Actors::Environment] env
        # @return [true, false]
        def date_uploaded_present?(env)
          env.attributes[:date_uploaded].present? || env.curation_concern.date_uploaded.present?
        end

        # @param [Hyrax::Actors::Environment] env
        # @return [DateTime]
        def get_date_uploaded_value(env)
          concern = env.curation_concern

          if concern.date_uploaded.present?
            # calling `#to_s` allows us to recycle a previous Time value
            # or use a string attached to the model (not recommended!)
            DateTime.parse(concern.date_uploaded.to_s).utc
          elsif env.attributes[:date_uploaded].present?
            DateTime.parse(env.attributes[:date_uploaded]).utc
          else
            # Probably unnecessary but I don't want to leave any mystery
            TimeService.time_in_utc
          end
        end
    end
  end
end
