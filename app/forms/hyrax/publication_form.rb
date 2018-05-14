module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Publication

    self.required_fields = [
      :title,
      :contributor,
      :date_created,
      :issued,
      :available,
      :rights_statement
    ]

    self.terms = [
      # required fields
      :title,
      :contributor,
      :date_created,
      :issued,
      :available,
      :rights_statement,

      # optional fields
      :creator,
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

    def self.singular_fields
      [
        :title,
        :type,
        :abstract,
        :issued,
        :available,
        :date_created
      ]
    end

    def self.multiple?(field)
      if singular_fields.include? field.to_sym
        false
      else
        super
      end
    end
  end
end
