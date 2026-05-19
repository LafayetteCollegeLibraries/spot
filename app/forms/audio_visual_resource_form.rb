# frozen_string_literal: true
class AudioVisualResourceForm < Hyrax::Forms::ResourceForm(AudioVisualResource)

  include Hyrax::FormFields(:core_metadata)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:audio_visual_metadata)
end
