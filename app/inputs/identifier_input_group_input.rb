# frozen_string_literal: true

class IdentifierInputGroupInput < MultiValueInput
  def input_type
    'multi_value'
  end

  private

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

  def build_input_dropdown(selected = nil)
    button_text = selected ? label_for(selected) : 'Select type'
    <<-HTML
    <select class="custom-select form-control" name="#{object_name}[identifier_prefix][]" autocomplete="off">
      <option value="">Select type</option>
      #{prefixes.each_with_object([]) do |prefix, output|
        output << %(
          <option value="#{prefix}"#{ ' selected' if prefix == selected}>
            #{label_for(prefix)}
          </option>
        )
      end.join.html_safe}
    </select>
    HTML
  end

  def build_input(value, index)
    %(<input type="text" name="#{object_name}[identifier_value][]" class="form-control" value="#{value}"/>)
  end

  def prefixes
    Spot::Identifier.prefixes
  end

  def label_for(prefix)
    Spot::Identifier.new(prefix, nil).prefix_label
  end
end
