# frozen_string_literal: true
#
class LanguageTaggedInputGroupInput < SimpleForm::Inputs::Base
  include LanguageTagging

  def input_type
    'text language_tagged'
  end

  # borrows a lot from hydra-editor's MultiValueInput but strips out
  # the multi-input part
  #
  # @param [Hash] wrapper_options
  # @return [] text input
  def input(wrapper_options = nil)
    input_html_classes.unshift('string')
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}]"
    value = object.send(attribute_name) || ''

    build_field(value, nil)
  end
end
