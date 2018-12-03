# frozen_string_literal: true
#
# This input is used for fields that will become language-tagged
# rdf literals. Instead of solely a text input, we're rendering
# _two_ inputs: one for the value and one for the language. These
# are then merged in the form into a single RDF::Literal with
# the language tagged.
class LanguageTaggedInputGroupInput < MultiValueInput
  def input_type
    'multi_value'
  end

  private

  def build_field(raw_value, index)
    value, language = parse_value(raw_value)

    <<-HTML
    <div class="row form-inline">
      <div class="form-group col-sm-10">
        #{build_input(value, index)}
      </div>
      <div class="form-group col-sm-2">
        #{build_language_autocomplete(language)}
      </div>
    </div>
    HTML
  end

  def build_input(value, index)
    # this is coming from MultiValueInput
    options = build_field_options(value, index)

    # convert name from 'publication[title][]' to 'publication[title_value][]'
    options[:name] = options[:name].gsub(/\[([^\]]+)\]/, '[\1_value]')

    if options.delete(:type) == 'textarea'
      @builder.text_area(attribute_name, options)
    else
      @builder.text_field(attribute_name, options)
    end
  end

  # normally we'd just generate a <select>, but there are
  # a _lot_ of options available, so we'll build a jquery-ui
  # autocomplete + do some validation on the input afterwards.
  def build_language_autocomplete(val)
    label = language_label(val)
    options = {
      value: val,
      name: "#{object_name}[#{attribute_name}_language][]",
      class: 'form-control',
      data: {
        'autocomplete-url': '/authorities/search/language',
        'autocomplete': 'language-label'
      }
    }

    @builder.text_field("#{attribute_name}_language", options)
  end

  def language_label(key)
    Spot::ISO6391.label_for(key.to_s)
  end

  def parse_value(raw)
    return [raw.value, raw.language] if raw.is_a? RDF::Literal
    return [raw, nil] if raw.present?
    return [nil, nil]
  end
end
