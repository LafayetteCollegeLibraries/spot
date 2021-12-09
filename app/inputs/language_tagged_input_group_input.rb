# frozen_string_literal: true
#
# A +simple-form+ element that appends an autocomplete input
# to tag the value in a certain language. This relies heavily
# on the {LanguageTagging} mixin for the rendering.
#
# This input is used for single-valued properties. For multiple
# inputs, see {LanguageTaggedMultiInputGroupInput}.
#
# @example
#   <%# app/views/records/edit_fields/_title.html.erb %>
#   <%= f.input :title, as: :language_tagged_input_group %>
#
class LanguageTaggedInputGroupInput < SimpleForm::Inputs::Base
  include LanguageTagging

  # Appends 'language_tagged' to a default value. This provides us
  # with a target for the jQuery. NOTE: changing this value may
  # upset the JS; please be careful!
  #
  # @return [String]
  def input_type
    'text language_tagged'
  end

  # borrows a lot from hydra-editor's MultiValueInput but strips out
  # the multi-input part
  #
  # @param [Hash] wrapper_options
  # @return [] text input
  def input(_wrapper_options = nil)
    input_html_classes.unshift('string')
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}]"
    value = object.send(attribute_name) || ''

    build_field(value, nil)
  end

private

  # Explicitly state that this is a single property, rather than expecting
  # this method to not be defined.
  #
  # @return [FalseClass]
  def multiple?
    false
  end
end
