# frozen_string_literal: true
#
# A +simple-form+ element that provides a drop-down select and text-input
# for identifiers to allow prefixes to be appended. As stored, our identifiers
# look like: `<prefix>:<value>` (see {Spot::Identifier}), but we would like
# to remove the perils of conformance as much as possible and thus provide
# a way to simplify the input process.
#
# @example
#   <%# app/views/records/edit_fields/_identifier.html.erb %>
#   <%= f.input :identifier, as: :identifier_input_group %>
#
# @todo abstract out the input 'name' field, so that a differently named
#       property can perform similarly.
class IdentifierInputGroupInput < MultiValueInput
  # We want to preserve the look + feel of multi-value input, so we'll
  # stuff this value (which is added as a class name to the wrapper element)
  #
  # @return [String]
  def input_type
    'multi_value'
  end

  private

    # Called from {MultiValueInput#input} to build out the HTML of the input.
    #
    # @param [String] raw_value
    # @param [Integer] index
    # @return [String] HTML output
    def build_field(raw_value, index)
      identifier = Spot::Identifier.from_string(raw_value)

      <<-HTML
      <div class="row">
        <div class="col-sm-4">
          #{build_input_dropdown(identifier.prefix)}
        </div>
        <div class="col-sm-8">
          #{build_input(identifier.value, index)}
        </div>
      </div>
      HTML
    end

    # Builds out the select dropdown with prefixes from {Spot::Identifier.prefixes}
    #
    # @todo could this be moved into a FormBuilder method call?
    # @todo abstract out the +<select>+ element's +name+ attribute
    # @param [String] the currently selected prefix
    # @return [String] HTML for the dropdown
    def build_input_dropdown(selected = nil)
      <<-HTML
      <select class="custom-select form-control" name="#{object_name}[identifier_prefix][]" autocomplete="off">
        <option value="">Select type</option>
        #{prefixes.each_with_object([]) do |prefix, output|
          output << %(
            <option value="#{prefix}" #{'selected' if prefix == selected}>
              #{label_for(prefix)}
            </option>
          )
        end.join.html_safe}
      </select>
      HTML
    end

    # Builds out the text input for the identifier
    #
    # @todo can we move this to a FormBuilder method call?
    # @todo abstract out the +name+ attribute
    # @param [String] value
    # @param [Integer] _index (not used)
    # @return [String] HTML output for the +<input>+ element
    def build_input(value, _index)
      %(<input type="text" name="#{object_name}[identifier_value][]" class="form-control" value="#{value}"/>)
    end

    # @return [Array<String>] curated prefixes
    def prefixes
      Spot::Identifier.standard_prefixes
    end

    # Grabs the prefix label from {Spot::Identifier}
    #
    # @param [String] prefix
    # @return [String]
    def label_for(prefix)
      Spot::Identifier.new(prefix, nil).prefix_label
    end
end
