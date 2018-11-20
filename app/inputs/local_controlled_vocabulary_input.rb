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
#       case 'based_near':
#       case 'new_field_name':
#         new LinkedData(element, url)
#     }
#   }
#
# Because this isn't a "traditional" nested_attributes case,
# you'll have to add handling for this field within your
# hydra-editor form.
class LocalControlledVocabularyInput < ControlledVocabularyInput
  def input_type
    'controlled_vocabulary'
  end

  private

  def build_field(value, index)
    options = input_html_options.dup
    build_options(value, index, options)

    @rendered_first_element = true

    text_field(options) + hidden_id_field(value, index) + destroy_widget(attribute_name, index)
  end

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

  def hidden_id_field(value, index)
    name = name_for(attribute_name, index, 'id')
    id = id_for(attribute_name, index, 'id')

    @builder.hidden_field(attribute_name,
                          name: name,
                          id: id,
                          value: value,
                          data: { id: 'remote' })
  end

  def collection
    @collection ||= begin
                      val = object[attribute_name]
                      col = val.respond_to?(:to_ary) ? val.to_ary : val
                      col.reject { |value| value.to_s.strip.blank? } + ['']
                    end
  end
end
