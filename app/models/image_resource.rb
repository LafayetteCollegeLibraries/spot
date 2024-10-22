# frozen_string_literal: true
class ImageResource < ::Hyrax::Work
  include Hyrax::Schema(:base_metadata)
  include Hyrax::Schema(:image_metadata)
end
