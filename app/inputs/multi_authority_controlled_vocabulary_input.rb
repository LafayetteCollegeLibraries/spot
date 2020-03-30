# frozen_string_literal: true
#
# @todo There's probably a world/future where the work of this input and
#       {StandardIdentifierInputGroupInput} could be extracted as a common-
#       denominator for providing the skeleton of multi-values that render
#       a dropdown and an input.
class MultiAuthorityControlledVocabularyInput < ControlledVocabularyInput
  def input_type
    'multi_value multi_authority'
  end

  private

    def build_field(raw_value, index)
      authorities = authority_select_options
      return if authorities.empty?

      <<-HTML
      <div class="row">
        <!-- authority-select dropdown -->
        <div class="col-sm-4">
          #{build_authority_dropdown(raw_value, index, authorities)}
        </div>

        <!-- field input -->
        <div class="col-sm-8">
          #{build_input(raw_value, index)}
        </div>
      </div>
      HTML
    end

    # @return [Array<#to_s>]
    def authority_select_options
      return [] unless options.include?(:authorities)
      options[:authorities].dup
    end

    # @return [String]
    def build_authority_dropdown(value, index, authorities)
      <<-HTML
      <select class="form-control authority-select">
        <option value="" selected>pick an authority</option>
        #{authority_option_html(authorities)}
      </select>
      HTML
    end

    # @return [String]
    def build_input(raw_value, index)
      options = {
        class: 'form-control',
        data: { autocomplete: attribute_name },
        readonly: true,
        value: raw_value
      }

      @builder.text_field(attribute_name, options)
    end

    # @return [Spot::AuthoritySelectService]
    def select_service
      @select_service ||= Spot::AuthoritySelectService.new
    end

    # @param [Array<Symbol,String>]
    # @return [String]
    def authority_option_html(authorities)
      select_service.select_options_for(*authorities).map do |auth|
        %(<option value="#{auth[:search]}">#{auth[:label]}</option>)
      end.join.html_safe
    end
end
