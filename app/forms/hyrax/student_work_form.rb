# frozen_string_literal: true
module Hyrax
  class StudentWorkForm < ::Spot::Forms::WorkForm
    singular_form_fields :title, :description, :date, :date_available, :rights_statement

    self.model_class = ::StudentWork
    self.required_fields = [
      :title, :creator, :advisor, :academic_department, :division,
      :description, :date, :date_available, :rights_statement, :resource_type
    ]

    self.terms = [
      # required
      :title,
      :creator,
      :advisor,
      :academic_department,
      :division,
      :description,
      :date,
      :date_available,
      :rights_statement,
      :resource_type,

      # below the fold
      :abstract,
      :language,
      :related_resource,
      :access_note,

      # librarian-added fields, applied during review
      :organization,
      :subject,
      :keyword,
      :bibliographic_citation,
      :identifier,
      :note
    ].concat(hyrax_form_fields)

    def primary_terms
      [
        :title, :creator, :advisor, :academic_department, :division, :description,
        :date, :date_available, :rights_statement, :resource_type
      ]
    end
  end
end
