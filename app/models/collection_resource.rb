# frozen_string_literal: true
class CollectionResource < Hyrax::PcdmCollection
  include Hyrax::Schema(:core_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:collection_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
end
