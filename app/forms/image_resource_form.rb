# frozen_string_literal: true
class ImageResourceForm < Hyrax::Forms::ResourceForm(ImageResource)
  include Hyrax::FormFields(:core_metadata)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:image_metadata)
end
