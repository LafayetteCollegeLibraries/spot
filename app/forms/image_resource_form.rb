# frozen_string_literal: true
#
# Form to edit ImageResource objects, added for use with Hyrax's Valkyrie adapter.
#
# @note need to :save_constantize Hyrax's ResourceForm so that the class is loaded
#       + Rails knows about their new constant-method approach (otherwise this will
#       raise a NoMethodError for :ResourceForm on the Hyrax::Forms module)
#
# @example Creating a form for a new resource (Hyrax v4.0)
#   form = Hyrax::Forms::ResourceForm.for(ImageResource.new)
#
# @example Creating a form for a new resource (Hyrax >= v5.0)
#   form = Hyrax::Forms::ResourceForm.for(resource: ImageResource.new)
#
# @example Creating a form for an existing resource (Hyrax v4.0)
#   resource = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: 'abc123def')
#   form = Hyrax::Forms::ResourceForm.for(resource)
#
# @example Creating a form for an existing resource (hyrax >= v5.0)
#   resource = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: 'abc123def')
#   form = Hyrax::Forms::ResourceForm.for(resource: resource)
#
'Hyrax::Forms::ResourceForm'.safe_constantize

class ImageResourceForm < ::Hyrax::Forms::ResourceForm(ImageResource)
  include Spot::Forms::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:image_metadata)
  include Spot::Forms::IdentifierFormFields

  include Spot::Forms::LanguageTaggedFormFields.for(:title, :title_alternative, :subtitle, :description, :inscription)
  include Spot::Forms::ControlledVocabularyFormField.for(:language)
  include Spot::Forms::ControlledVocabularyFormField.for(:subject_ocm)
  include Spot::Forms::ControlledVocabularyFormField.for(:location, model_wrapper: Spot::ControlledVocabularies::Location)
  include Spot::Forms::ControlledVocabularyFormField.for(:subject, model_wrapper: Spot::ControlledVocabularies::AssignFastSubject)

  validates_with Spot::EdtfDateValidator, fields: [:date]

  # Define the order in which we display fields for the user. These are rendered
  # "above the fold," or unobscurred by a hideaway toggle.
  #
  # @return [Array<Symbol>]
  # @todo Should we move repository-centric fields to #secondary_terms or does it not really
  #       matter for a staff-side object?
  #
  # rubocop:disable Metrics/MethodLength
  def primary_terms
    [
      :title,
      :date,
      :resource_type,
      :rights_statement,

      # non-required fields
      :title_alternative,
      :subtitle,
      :date_associated,
      :date_scope_note,
      :rights_holder,
      :description,
      :inscription,
      :creator,
      :contributor,
      :publisher,
      :keyword,
      :subject,
      :location,
      :language,
      :source,
      :physical_medium,
      :original_item_extent,
      :repository_location,
      :requested_by,
      :research_assistance,
      :donor,
      :related_resource,
      :local_identifier,
      :subject_ocm,
      :note
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
