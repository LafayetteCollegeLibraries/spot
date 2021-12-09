# frozen_string_literal: true
#
# A mixin to provide a single source for building out language-tagged
# inputs on a form. If inheriting from MultiValueInput, it's as simple
# as including this module and defining an :input_type method (so the
# appropriate class is added to the html element).
#
# @example
#   class SomeMultiTaggedInput < MultiValueInput
#     include LanguageTagging
#
#     def input_type
#       'multi_value language_tagged'
#     end
#   end
#
# Note: you need to include 'language_tagged' in the input type in order
# for the javascript to work correctly.
#
# If extending a single-value item, you'll need to provide an :input
# method (which +hydra-editor+ is expecting) and have it create a
# +name+ option.
#
# @example
#   class SingleTaggedInput < MultiValueInput
#     include LanguageTagging
#
#     def input_type
#       'text language_tagged'
#     end
#
#     def input(wrapper_options = nil)
#       input_html_options[:name] ||= "#{object_name}[#{attribute_name}]"
#       value = object.send(attribute_name) || ''
#       build_field(value, nil)
#     end
#   end
#
# This module relies on some ruby magic re: checking inheritance
# (see: #build_field_options, #autocomplete_name) and I have some
# concerns about its fragility. But so far so good!
module LanguageTagging
  # Overriding the default method to append a notice that this field can be
  # tagged with a language.
  #
  # @todo move this to a locale
  # @param [Hash] _wrapper_options Not used
  # @return [String]
  def hint(_wrapper_options = nil)
    default_hint = super
    return unless default_hint

    "#{default_hint} <strong>#{hint_text}</strong>".html_safe
  end

private

  # If inheriting from MultiValueInput, this method is called from
  # the +#input+ method (which itself is called from within the
  # hydra-form gem). Otherwise, you can use this from within your
  # own +#input+ method.
  #
  # @param [RDF::Literal, String] raw_value
  # @param [Integer] _index not used
  # @return [String] HTML content for field row
  def build_field(raw_value, index = nil)
    value, language = parse_value(raw_value)

    <<-HTML
      <div class="row">
        <div class="col-sm-10">
          #{build_input(value, index)}
        </div>
        <div class="col-sm-2">
          #{build_language_autocomplete(language)}
        </div>
      </div>
      HTML
  end

  # Responsible for building the input for the property value
  # (not language tag). It'll produce a name similar to
  # +work_type[field_value]+
  #
  # @param [String] value
  # @param [Integer] index
  # @return [String]
  def build_input(value, index)
    options = build_field_options(value, index)

    # convert name from 'publication[title]' to 'publication[title_value]'
    options[:name] = options[:name].gsub(/\[([^\]]+)\]/, '[\1_value]')

    if options.delete(:type).to_s == 'textarea'
      @builder.text_area(attribute_name, options)
    else
      @builder.text_field(attribute_name, options)
    end
  end

  # normally we'd just generate a <select>, but there are
  # a _lot_ of options available, so we'll build a jquery-ui
  # autocomplete + do some validation on the input afterwards.
  #
  # @param [String] val
  # @return [String]
  def build_language_autocomplete(val)
    options = {
      value: val,
      name: autocomplete_name,
      placeholder: autocomplete_placeholder,
      class: 'form-control',
      data: {
        'autocomplete-url': '/authorities/search/language',
        'autocomplete': 'language-label'
      }
    }

    @builder.text_field("#{attribute_name}_language", options)
  end

  # a minimal implementation of MultiValueInput#build_field_options
  # for input classes that _don't_ extend from MVI or have this
  # method already defined
  #
  # @param [String] value
  # @param [Integer] _index (not used here)
  # @return [Hash<Symbol => *>]
  def build_field_options(value, _index)
    return super if defined?(super)

    dom_id = input_dom_id if respond_to?(:input_dom_id)
    dom_id ||= "#{object_name}_#{attribute_name}"

    input_html_options.dup.tap do |options|
      options[:value] = value

      options[:id] ||= dom_id
      options[:class] ||= []
      options[:class] += ["#{dom_id} form-control"]
      options[:'aria-labelledby'] ||= "#{dom_id}_label"
    end
  end

  # @todo move this to a locale
  # @return [String]
  def hint_text
    'This field may be tagged with a language'
  end

  # Generates a name property for the autocomplete input.
  #
  # @return [String]
  def autocomplete_name
    base = "#{object_name}[#{attribute_name}_language]"

    return base unless multiple_method? && multiple?

    "#{base}[]"
  end

  # @todo move this to a locale
  # @return [String]
  def autocomplete_placeholder
    'Language'
  end

  # This has a pretty bad code-smell, but it's the best solution I could
  # come up with. Does this Input have a +#multiple?+ method defined?
  #
  # @return [TrueClass, FalseClass]
  def multiple_method?
    private_methods.include?(:multiple?) || methods.include?(:multiple?)
  end

  # extract the value + language from possible raw values: either an RDF::Literal
  # or a String value (or neither).
  #
  # @return [Array<String>]
  def parse_value(raw)
    return [raw.value, raw.language] if raw.is_a? RDF::Literal
    return [raw, nil] if raw.present?
    [nil, nil]
  end
end
