# frozen_string_literal: true
class PublicationResource < BaseResource
  include Hyrax::Schema(:institutional_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:publication_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  Hyrax::ValkyrieLazyMigration.migrating(self, from: ::Publication)
end
