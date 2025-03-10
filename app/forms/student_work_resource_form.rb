# frozen_string_literal: true
# Form to edit StudentWorkResource objects
#
# @todo In StudentWorkForm we default :creator and :rights_holder to the name
#       of the depositing user, but I don't think we have a hook in the form.
#       This might need to be added at the controller level.
class StudentWorkResourceForm < ::Hyrax::Forms::ResourceForm(StudentWorkResource)
  DEFAULT_RIGHTS_STATEMENT_URI = 'http://rightsstatements.org/vocab/InC-EDU/1.0/'

  include Spot::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:institutional_metadata)
  include Hyrax::FormFields(:student_work_metadata)

  include Spot::ControlledVocabularyFormField(:location, vocabulary_class: Spot::ControlledVocabularies::Location)
  include Spot::ControlledVocabularyFormField(:subject, vocabulary_class: Spot::ControlledVocabularies::AssignFastSubject)
  include Spot::ControlledVocabularyFormField(:academic_department)
  include Spot::ControlledVocabularyFormField(:advisor)
  include Spot::ControlledVocabularyFormField(:division)
  include Spot::ControlledVocabularyFormField(:language)

  include Spot::IdentifierFormFields

  validates_with Spot::EdtfDateValidator, fields: [:date]

  # Hack to allow us to override certain form fields to make them singular when they're multiple
  # in other places. We were able to do this in earlier Hyrax forms by evaluating the user accessing
  # the form, but I think that behavior is decoupled in the Valkyrized world and performed during
  # the change_set saving transaction (iirc).
  %w[
    abstract
    date
    date_available
    description
  ].each { |field| self.definitions[field].merge!(multiple: false) }

  # @todo provide the StudentWork admin_set as a default? Or stuff the value and not expose it?
  # def admin_set_id; end

  def primary_terms
    [
      :title,
      :creator,
      :advisor,
      :academic_department,
      :description,
      :date,
      :date_available,
      :resource_type,
      :rights_statement,
      :rights_holder
    ]
  end

  def secondary_terms
    [
      :division,
      :abstract,
      :language,
      :related_resource,
      :organization,
      :subject,
      :keyword,
      :bibliographic_citation,
      :standard_identifier,
      :access_note,
      :note
    ]
  end

  def description
    Array.wrap(super).first
  end

  def rights_statement
    super || [DEFAULT_RIGHTS_STATEMENT_URI]
  end
end
