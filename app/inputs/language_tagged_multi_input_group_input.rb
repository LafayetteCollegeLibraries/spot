# frozen_string_literal: true

class LanguageTaggedMultiInputGroupInput < MultiValueInput
  include LanguageTagging

  def input_type
    'multi_value language_tagged'
  end
end
