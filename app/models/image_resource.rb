# frozen_string_literal: true
class ImageResource < BaseResource
  include Hyrax::Schema(:image_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  Hyrax::ValkyrieLazyMigration.migrating(self, from: ::Image)
end
