# frozen_string_literal: true
class ImageResource < ::Hyrax::Work
  include Hyrax::Schema(:base_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:image_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
end
