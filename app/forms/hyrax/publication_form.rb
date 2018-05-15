module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Publication

    self.required_fields = [
      :title,
      :date_created,
      :issued,
      :available,
      :rights_statement
    ]

    self.terms = required_fields + [
      # optional fields
      :creator,
      :contributor,
      :publisher,
      :source,
      :resource_type,
      :language,
      :abstract,
      :description,
      :identifier,
      :academic_department,
      :division,
      :organization,

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
      singular_fields = %i(resource_type abstract issued available date_created)
      super.tap do |attrs|
        singular_fields.each do |field|
          attrs[field] = Array(attrs[field]) if attrs[field]
        end
      end
    end

    def multiple?(field)
      singular_fields = %i(resource_type abstract issued available date_created)
      if singular_fields.include? field.to_sym
        false
      else
        super
      end
    end
  end
end
