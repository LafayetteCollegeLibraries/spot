# frozen_string_literal: true
#
# An input for rendering a controlled vocabulary input with a <select>
# element to toggle the URI source.
#
# @example usage in a field
#   # app/views/records/edit_fields/_some_field.html.erb
#   # note: the values for the "authorities" property are the ids
#   # in config/authorities/remote_authorities.yml
#   <%=
#       f.input :some_field,
#       as: :multi_authority_controlled_vocabulary,
#       placeholder: 'Search for a value',
#       authorities: [:geonames, :fast],
#       wrapper_html: { data: { 'field-name' => 'some_field' } },
#       required: f.object.required?(:some_field)
#   %>
#
class MultiAuthorityControlledVocabularyInput < ControlledVocabularyInput
  def input_type
    'multi_auth_controlled_vocabulary'
  end

  private

    # @todo only display the value if it already exists (don't supply the dropdown
    #       for pre-existing values).
    def build_field(value, index)
      authorities = options.include?(:authorities) ? options[:authorities].dup : []
      return if authorities.empty?

      <<-HTML
      <div class="row">
        #{authority_dropdown(authorities, index) if value.node?}

        <div class="col-sm-#{value.node? ? '8' : '12'}">
          #{super}
        </div>
      </div>
      HTML
    end

    # sets options if we're creating a new row (+value.node?+ is true). since
    # we need to set the authority first, our input needs to be read-only.
    #
    # @param [String] _attribute_name
    # @param [Number] _index
    # @param [Hash] options
    # @return [void]
    def build_options_for_new_row(attribute_name, _index, options)
      super

      options[:readonly] = true
      options[:data] ||= {}
      options[:data][:autocomplete] = attribute_name
    end

    # updating the existing method to display both the rdf label + subject
    # (note: this impacts the +hidden_label+ attribute, which is the value displayed,
    # and _not_ the underlying value.)
    #
    # @todo do we want to patch this into +ControlledVocabularyInput+?
    # @return [void]
    def build_options_for_existing_row(_attribute_name, _index, value, options)
      options[:value] = "#{value.rdf_label.first} (#{value.rdf_subject})" || "Unable to fetch label for #{value.rdf_subject}"
      options[:readonly] = true
    end

    # Builds out the values for our object and inserts an empty option at the end
    #
    # @return [Array<ActiveTriples::Resource>]
    def collection
      @collection ||= collection_values
    end

    # @return [Array<ActiveTriples::Resource>]
    def collection_values
      val = object[attribute_name]
      col = val.respond_to?(:to_ary) ? val.to_ary : val
      col.reject { |value| value.respond_to?(:node?) ? value.node? : value.to_s.strip.blank? } + [cv_klass.new]
    end

    # class name of the controlled vocabulary for this property
    #
    # @return [Class]
    def cv_klass
      object.model.class.properties[attribute_name.to_s].class_name
    end

    def id_for_select(index)
      "#{@builder.object_name}_#{attribute_name}_authority_select_#{index}"
    end

    # @return [Spot::AuthoritySelectService]
    def select_service
      @select_service ||= Spot::AuthoritySelectService.new
    end

    # @return [String]
    def authority_option_html(authorities)
      select_service.select_options_for(*authorities).map do |auth|
        %(<option value="#{auth[:search]}">#{auth[:label]}</option>)
      end.join.html_safe
    end

    # @todo make this an i18n translation
    # @return [String]
    def authority_dropdown(authorities, index)
      <<-HTML
      <div class="col-sm-4">
        <select id="#{id_for_select(index)}" class="form-control authority-select" name="#{id_for_select(index)}">
          <option value="" selected>Select an Authority source</option>
          #{authority_option_html(authorities)}
        </select>
      </div>
      HTML
    end
end
