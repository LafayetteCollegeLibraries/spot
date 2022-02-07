# frozen_string_literal: true
module Spot
  module Actors
    # Starting point for Spot models. Adds mixin to better pass-around
    # RDF language-tagged values (see {::DeserializesRdfLiterals})
    # as well as allowing us to apply a +date_uploaded+ value on +#create+.
    #
    # @example
    #   module Hyrax
    #     class WorkActor < ::Spot::BaseActor
    #     end
    #   end
    #
    class BaseActor < ::Hyrax::Actors::BaseActor
      include ::DeserializesRdfLiterals

      private

      # Overrides the BaseActor method to allow us to stuff in
      # `date_uploaded` values where necessary.
      #
      # @return [void]
      def apply_deposit_date(env)
        env.curation_concern.date_uploaded = get_date_uploaded_value(env)
      end

      # if we've been passed attributes with a :rights_statement value, convert it
      # to an RDF::URI object for storage
      #
      # @param [Hyrax::Actors::Environment] env
      # @return [void]
      def apply_save_data_to_curation_concern(env)
        transform_rights_statement(env) if env.attributes.key?(:rights_statement)

        super
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
          ::Hyrax::TimeService.time_in_utc
        end
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [void]
      def transform_rights_statement(env)
        env.attributes[:rights_statement] = Array.wrap(env.attributes[:rights_statement]).map { |v| RDF::URI(v) }
      end
    end
  end
end
