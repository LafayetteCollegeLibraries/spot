# frozen_string_literal: true
#
# Form to edit StudentWorkResource objects
#
# @todo In StudentWorkForm we default :creator and :rights_holder to the name
#       of the depositing user, but I don't think we have a hook in the form.
#       This might need to be added at the controller level.
#
# @todo Update 2025-06-23: we can do this by adding a prepopulator for those
#       fields and evaluating the ability by instantiating a User using the
#       `resource.depositor` email (which is added to the resource before
#       a new form is created). Defining the prepopulator might be as simple as
#       defining a `:<field>_prepopulator` method + maybe overriding the field configuration
#       similarly to how we're creating single fields for students (which itself needs
#       to be revisited)
# @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/controllers/concerns/hyrax/works_controller_behavior.rb#L57
'Hyrax::Forms::ResourceForm'.safe_constantize

class StudentWorkResourceForm < ::Hyrax::Forms::ResourceForm(StudentWorkResource)
  DEFAULT_RIGHTS_STATEMENT_URI = 'http://rightsstatements.org/vocab/InC-EDU/1.0/'

  include Spot::Forms::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:institutional_metadata)
  include Hyrax::FormFields(:student_work_metadata)

  include Spot::Forms::ControlledVocabularyFormField.for(:location, model_wrapper: Spot::ControlledVocabularies::Location)
  include Spot::Forms::ControlledVocabularyFormField.for(:subject, model_wrapper: Spot::ControlledVocabularies::AssignFastSubject)
  include Spot::Forms::ControlledVocabularyFormField.for(:academic_department)
  include Spot::Forms::ControlledVocabularyFormField.for(:advisor)
  include Spot::Forms::ControlledVocabularyFormField.for(:division)
  include Spot::Forms::ControlledVocabularyFormField.for(:language)

  include Spot::Forms::IdentifierFormFields

  validates_with Spot::EdtfDateValidator, fields: [:date]

  # Hack to allow us to override certain form fields to make them singular when they're multiple
  # in other places. We were able to do this in earlier Hyrax forms by evaluating the user accessing
  # the form, but I think that behavior is decoupled in the Valkyrized world and performed during
  # the change_set saving transaction (iirc).
  %w[abstract date date_available description].each do |field|
    definitions[field].merge!(multiple: false, default: proc { nil })
  end

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
