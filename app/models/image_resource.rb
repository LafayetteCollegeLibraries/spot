# frozen_string_literal: true
class ImageResource < BaseResource
  include Hyrax::Schema(:core_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:base_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:image_metadata, schema_loader: Spot::SimpleSchemaLoader.new)

  def identifier
    attributes[:identifier].map { |v| v.is_a?(String) ? Spot::Identifier.from_string(v) : v }
  end

  def local_identifier
    identifier.select(&:local?)
  end

  def standard_identifier
    identifier.select(&:standard?)
  end
end
