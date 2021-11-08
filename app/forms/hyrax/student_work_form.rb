# frozen_string_literal: true
module Hyrax
  class StudentWorkForm < ::Spot::Forms::WorkForm
    singular_form_fields :title

    self.model_class = ::StudentWork
    self.required_fields = [:title, :resource_type, :rights_statement]

    # @todo finish ordering this
    self.terms = [
      # required
      :title,
      :resource_type,
      :rights_statement,

      # ... and the rest!
      :title_alternative,

      :creator,
      :contributor,

      :abstract,
      :description,
      :date,
      :date_available,
      :language,
      :location,
      :physical_medium,
      :publisher,
      :identifier,
      :keyword,
      :related_resource,
      :resource_type,
      :source,
      :subject,
      :subtitle,

      # institutional metadata
      :advisor,
      :academic_department,
      :division,
      :organization,

      # rights
      :rights_holder,
      :rights_statement,

      :bibliographic_citation,
      :access_note,
      :note
    ].concat(hyrax_form_fields)
  end
end
