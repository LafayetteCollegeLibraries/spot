# frozen_string_literal: true
class PublicationResource < ::Hyrax::Work
  include Hyrax::Schema(:base_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:institutional_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:publication_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  include Spot::BaseResourceBehavior
end
