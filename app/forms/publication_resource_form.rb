# frozen_string_literal: true
# Form to edit PublicationResource objects
class PublicationResourceForm < ::Hyrax::Forms::ResourceForm(PublicationResource)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:institutional_metadata)
  include Hyrax::FormFields(:publication_metadata)

  include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :abstract, :description)
  include Spot::NestedAttributeFormFields(:subject, :language, :academic_department, :division)
  include Spot::IdentifierFormFields

  validates_with Spot::EdtfDateValidator, fields: [:date_issued]

  # Set a date_available value to either the embargo's release date (where present)
  # or the current day, in YYYY-MM-DD format.
  #
  # @return [Array<String>]
  # @note replaces work done in Hyrax::Actors::PublicationActor
  def date_available
    value = super
    return value if value.present?

    if embargo_release_date.present?
      [embargo_release_date.strftime('%Y-%m-%d')]
    else
      [Time.zone.now.strftime('%Y-%m-%d')]
    end
  end
end
