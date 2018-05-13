module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Publication

    class << self
      def multiple?(field)
        if singular_fields.include? field.to_sym
          false
        else
          super
        end
      end

      def terms
        required_fields + optional_fields + internal_form_fields
      end

      def required_fields
        %i(
          title
          contributor
          date_created
          issued
          available
          rights_statement
        )
      end

      private

      def singular_fields
        %i(
          title
          type
          abstract
          issued
          available
          date_created
        )
      end

      def optional_fields
        %i(
          creator
          publisher
          source
          resource_type
          language
          abstract
          description
          identifier
          academic_department
          division
          organization
        )
      end

      def internal_form_fields
        %i(
          representative_id
          thumbnail_id
          files
          visibility_during_embargo
          visibility_after_embargo
          embargo_release_date
          visibility_during_lease
          visibility_after_lease
          lease_expiration_date
          visibility
          ordered_member_ids
          in_works_ids
          member_of_collection_ids
          admin_set_id
        )
      end
    end
  end
end
