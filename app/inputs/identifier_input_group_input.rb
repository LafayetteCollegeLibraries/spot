# frozen_string_literal: true

class IdentifierInputGroupInput < MultiValueInput
  def input_type
    'multi_value'
  end

  private

  def build_field(raw_value, index)
    identifier = Spot::Identifier.from_string(raw_value)

    <<-HTML
    <div class="input-group">
      #{build_input_dropdown(identifier.prefix)}
      #{build_input(identifier.value, index)}
    </div>
    HTML
  end

  def build_input_dropdown(selected = nil)
    button_text = selected ? label_for(selected) : 'Select type'
    <<-HTML
    <div class="input-group-btn">
      <button type="button" class="btn btn-default dropdown-toggle identifier-dropdown-toggle" data-toggle="dropdown">
        #{button_text} <span class="caret"></span>
      </button>
      <ul class="dropdown-menu identifier-prefix-select">
      #{prefixes.each_with_object([]) do |prefix, output|
        output << <<-HTML2
          <li#{' class="active"' if prefix == selected}>
            <a href="#" data-prefix="#{prefix}">#{label_for(prefix)}</a>
          </li>
        HTML2
      end.join.html_safe}
      </ul>
      <input type="hidden" name="#{object_name}[identifier_prefix][]" value="#{selected}" />
    </div>
    HTML
  end

  def build_input(value, index)
    %(<input type="text" name="#{object_name}[identifier_value][]" class="form-control" value="#{value}"/>)
  end

  def prefixes
    Spot::Identifier.prefixes
  end

  def label_for(prefix)
    t("spot.identifiers.labels.#{prefix}")
  end
end
