# frozen_string_literal: true
class PublicationResourceForm < Hyrax::Forms::ResourceForm(PublicationResource)
  include Hyrax::FormFields(:core_metadata)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:publication_metadata)
  include Hyrax::FormFields(:institutional_metadata)
end
