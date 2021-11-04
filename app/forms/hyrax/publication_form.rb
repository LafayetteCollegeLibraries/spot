# frozen_string_literal: true
module Hyrax
  class PublicationForm < ::Spot::Forms::WorkForm
    transforms_language_tags_for :title, :title_alternative, :subtitle, :abstract, :description
    transforms_nested_fields_for :language, :academic_department, :division
    singular_form_fields :abstract, :date_available, :date_created, :date_issued, :title

    self.model_class = ::Publication
    self.required_fields = [:title, :date_issued, :resource_type, :rights_statement]
    self.terms = [
      # required_fields first
      :title,
      :date_issued,
      :resource_type,
      :rights_statement,

      # starting with rights holder since it relates to rights_statement
      :rights_holder,
      :subtitle,
      :title_alternative,
      :creator,
      :contributor,
      :editor,
      :publisher,
      :source,
      :bibliographic_citation,
      :standard_identifier,
      :local_identifier,
      :abstract,
      :description,
      :subject,
      :keyword,
      :language,
      :physical_medium,
      :location,
      :note,
      :related_resource,
      :academic_department,
      :division,
      :organization
    ].concat(hyrax_form_fields)

    class << self
      def build_permitted_params
        super.tap do |params|
          params << { location_attributes: [:id, :_destroy] }
          params << { subject_attributes: [:id, :_destroy] }
        end
      end
    end
  end
end
