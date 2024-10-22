# frozen_string_literal: true
class PublicationResource < ::Hyrax::Work
  include Hyrax::Schema(:base_metadata)
  include Hyrax::Schema(:institutional_metadata)
  include Hyrax::Schema(:publication_metadata)
end
