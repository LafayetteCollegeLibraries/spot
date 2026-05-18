# frozen_string_literal: true
class PublicationResourceForm < Hyrax::Forms::ResourceForm(PublicationResource)
  include Spot::Forms::ResourceFormHelpers

  include Hyrax::FormFields(:core_metadata)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:publication_metadata)
  include Hyrax::FormFields(:institutional_metadata)

  language_tagged_field(:title, :title_alternative, :subtitle, :abstract, :description)
  nested_attributes_for(:subject, :location, :language, :academic_department, :division)
end
