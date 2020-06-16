# frozen_string_literal: true
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
        <div class="col-sm-4">
          #{authority_dropdown(authorities)}
        </div>
        <div class="col-sm-8">
          #{super}
        </div>
      </div>
      HTML
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
    def authority_dropdown(authorities)
      <<-HTML
      <select class="form-control authority-select">
        <option value="" selected>Select an Authority source</option>
        #{authority_option_html(authorities)}
      </select>
      HTML
    end
end
