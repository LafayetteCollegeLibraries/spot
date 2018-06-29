module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    SINGULAR_FIELDS = %i(
      resource_type
      abstract
      date_issued
      date_available
    )

    self.model_class = ::Publication

    self.required_fields = [
      :title,
    ]

    self.terms = required_fields + [
      :subtitle,
      :title_alternative,
      :publisher,
      :source,
      :resource_type,
      :language,
      :abstract,
      :description,
      :identifier,
      :bibliographic_citation,
      :date_issued,
      :date_available,
      :creator,
      :contributor,
      :editor,
      :academic_department,
      :division,
      :organization,

      # :related_resource

      :keyword,
      :subject,

      # :license
      :rights_statement,

      # optional fields

      # internal form fields
      :representative_id,
      :thumbnail_id,
      :files,
      :visibility_during_embargo,
      :visibility_after_embargo,
      :embargo_release_date,
      :visibility_during_lease,
      :visibility_after_lease,
      :lease_expiration_date,
      :visibility,
      :ordered_member_ids,
      :in_works_ids,
      :member_of_collection_ids,
      :admin_set_id
    ]

    def self.model_attributes(_)
      super.tap do |attrs|
        SINGULAR_FIELDS.each do |field|
          attrs[field] = Array(attrs[field]) if attrs[field]
        end
      end
    end

    def multiple?(field)
      if SINGULAR_FIELDS.include? field.to_sym
        false
      else
        super
      end
    end
  end
end
