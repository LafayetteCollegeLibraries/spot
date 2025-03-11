# frozen_string_literal: true
class PublicationResourceForm < ::Hyrax::Forms::ResourceForm(PublicationResource)
  include Spot::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:institutional_metadata)
  include Hyrax::FormFields(:publication_metadata)

  include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :abstract, :description)
  include Spot::IdentifierFormFields

  include Spot::ControlledVocabularyFormField(:location, vocabulary_class: Spot::ControlledVocabularies::Location)
  include Spot::ControlledVocabularyFormField(:subject, vocabulary_class: Spot::ControlledVocabularies::AssignFastSubject)
  include Spot::ControlledVocabularyFormField(:academic_department)
  include Spot::ControlledVocabularyFormField(:division)
  include Spot::ControlledVocabularyFormField(:language)

  validates_with Spot::EdtfDateValidator, fields: [:date_issued]

  # Set a date_available value to either the embargo's release date (where present)
  # or the current day, in YYYY-MM-DD format.
  validate(:date_available) do
    next if date_available.present?

    self.date_available =
      if embargo_release_date.present?
        date_time = embargo_release_date.respond_to?(:strftime) ? embargo_release_date : DateTime.parse(embargo_release_date.to_s)
        [date_time.strftime('%Y-%m-%d')]
      else
        [DateTime.now.strftime('%Y-%m-%d')]
      end
  end

  def primary_terms
    [
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
    ]
  end
end
