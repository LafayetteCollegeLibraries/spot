# frozen_string_literal: true
class AudioVisualResource < ::Hyrax::Work
  include Hyrax::Schema(:base_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
  include Hyrax::Schema(:audio_visual_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
end
