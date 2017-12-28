# Generated via
#  `rails generate hyrax:work Document`
module Hyrax
  class DocumentForm < Hyrax::Forms::WorkForm
    self.model_class = ::Document
    
    # if you want to change the order, the complete list is at
    # https://github.com/samvera/hyrax/blob/2.0-stable/app/forms/hyrax/forms/work_form.rb

    self.terms = [
      :title,
      :contributor,
      # :creator,
      :language,
      :abstract,
      :description,
      :identifier,
      :issued,
      :publisher,
      :date_created,
      :provenance,
      :department,
      :division,
      :organization,
      :subject,
      :related_url,
      :source,
      :license,
      :rights_statement,

      # these are internal things
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
      :admin_set_id,
     ]

    self.required_fields = [
      :title,
      :contributor,
    ]
  end
end
