# frozen_string_literal: true
#
# We're repurposing ControlledVocabularyInput to allow
# it to be used for local vocabularies (non-RDF values
# such as Language or Keyword).
#
# We're piggy-backing on the input JavaScript for +LinkedData+,
# so you'll need to add the field name to that +switch+
# statement within +app/assets/javascripts/hyrax/autocomplete.es6+
#
# @example
#   export default class Autocomplete {
#     setup(element, fieldName, url) {
#       // ...
#       case 'new_field_name':
#       case 'location':
#         new LinkedData(element, url)
#     }
#   }
#
# Because this isn't a "traditional" nested_attributes case,
# you'll have to add handling for this field within your
# hydra-editor form (see {NestedFormFields} concern).
class LocalControlledVocabularyInput < ControlledVocabularyInput
  # We want to piggy-back off the Hyrax ControlledVocabularyInput's
  # Javascript goodness, so we stuff that value to give the js something
  # to work with.
  #
  # @return [String]
  def input_type
    'controlled_vocabulary'
  end

  private

  # Copied from {Hyrax::ControlledVocabularyInput}, but strips out
  # any of the RDF-related work. This is called from
  # {LocalControlledVocabularyInput#input}.
  #
  # @param [String] value
  # @param [Integer] index
  # @return [String] HTML of the input
  def build_field(value, index)
    options = input_html_options.dup
    build_options(value, index, options)

    @rendered_first_element = true

    text_field(options) + hidden_id_field(value, index) + destroy_widget(attribute_name, index)
  end

  # Builds out the options used to render the text field.
  # Transforms the options object in place.
  #
  # @param [String] value
  # @param [Integer] index
  # @param [Hash] options dup'd from {LocalControlledVocabularyInput#input_html_options}
  # @return [void]
  def build_options(value, index, options)
    options[:name] = name_for(attribute_name, index, 'hidden_label')
    options[:data] ||= {}
    options[:data][:attribute] = attribute_name
    options[:id] = id_for_hidden_label(index)

    options[:value] = value || ''
    options[:readonly] = true if value.present?

    options[:required] = nil if @rendered_first_element
    options[:class] ||= []
    options[:class] += ["#{input_dom_id} form-control multi-text-field"]
    options[:'aria-labeledby'] = label_id
  end

  # Builds the +<input type="hidden"/>+ element used to capture the
  # ID from the js autocomplete widget.
  #
  # @param [String] value
  # @param [Integer] index
  # @return [String] HTML element
  def hidden_id_field(value, index)
    name = name_for(attribute_name, index, 'id')
    id = id_for(attribute_name, index, 'id')

    @builder.hidden_field(attribute_name,
                          name: name,
                          id: id,
                          value: value,
                          data: { id: 'remote' })
  end

  # Builds out the values for our object and inserts an empty option at the end
  #
  # @todo why is this here? :sweat_smile:
  # @return [Array<String>]
  def collection
    @collection ||= begin
                      val = object[attribute_name]
                      col = val.respond_to?(:to_ary) ? val.to_ary : val
                      col.reject { |value| value.to_s.strip.blank? } + ['']
                    end
  end
end
