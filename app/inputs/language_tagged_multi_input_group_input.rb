# frozen_string_literal: true
#
# A +simple-form+ element that appends a autocomplete inputs
# to tag the values in a certain language. This relies heavily
# on the {LanguageTagging} mixin for the rendering.
#
# This input is used for multi-valued properties. For single inputs,
# see {LanguageTaggedInputGroupInput}.
#
# @example
#   <%# app/views/records/edit_fields/_subtitle.html.erb %>
#   <%= f.input :subtitle, as: :language_tagged_multi_input_group %>
class LanguageTaggedMultiInputGroupInput < MultiValueInput
  include LanguageTagging

  # Appends 'language_tagged' to a default value. This provides us
  # with a target for the jQuery. NOTE: changing this value may
  # upset the JS; please be careful!
  #
  # @return [String]
  def input_type
    'multi_value language_tagged'
  end

private

  # Explicitly state that this is a multi-value property, rather than
  # expecting this method to be defined in MultiValueInput
  #
  # @return [TrueClass]
  def multiple?
    true
  end
end
