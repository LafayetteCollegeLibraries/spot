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

      # Allows for modifying env.attributes properties before the work is saved.
      #
      # @param [Hyrax::Actors::Environment] env
      # @return [void]
      def apply_save_data_to_curation_concern(env)
        transform_rights_statement(env) if env.attributes.key?(:rights_statement)
        transform_controlled_properties(env) if env.curation_concern.class.respond_to?(:controlled_properties)

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

      # We may need to convert controlled_properties form their string value
      # to their nested_attribute values (this came up with Bulkrax)
      #
      # @param [Hyrax::Actors::Environment] env
      # @return [void]
      def transform_controlled_properties(env)
        env.curation_concern.class.controlled_properties.map(&:to_s).each do |property|
          next if env.attributes[property].blank?

          values = env.attributes.delete(property)
          env.attributes[:"#{property}_attributes"] = Array.wrap(values).map { |value| { id: value } }
        end
      end

      # if we've been passed attributes with a :rights_statement value, convert it
      # to an RDF::URI object for storage
      #
      # @param [Hyrax::Actors::Environment] env
      # @return [void]
      def transform_rights_statement(env)
        env.attributes[:rights_statement] = Array.wrap(env.attributes[:rights_statement]).map { |v| RDF::URI(v) }
      end
    end
  end
end
