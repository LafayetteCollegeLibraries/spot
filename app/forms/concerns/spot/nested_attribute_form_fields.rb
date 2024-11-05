# frozen_string_literal: true
module Spot
  def self.NestedAttributeFormFields(*fields)
    NestedAttributeFormFields.new(fields)
  end

  # Adds support for nested attribute fields in Hyrax forms. These fields use Select2 in the UI
  # which sends data via a hash with numbered keys pointing at URI values.
  #
  # @usage
  #   module Hyrax
  #     class CoolResourceForm < Hyrax::ResourceForm(CoolResource)
  #       include Hyrax::Schema(:core_metadata)
  #       include Spot::NestedAttributeFormFields(:subject, :location)
  #     end
  #   end
  #
  # @example incoming *_attributes data
  #   {
  #      '0' => {
  #        'id' => 'https://ldr.lafayette.edu'
  #      },
  #      '1' => {
  #        'id' => 'https://lafayette.edu'
  #      }
  #   }
  #
  # @example incoming *_attributes data with deletion intention
  #   {
  #     '0' => {
  #       'id' => 'https://ldr.lafayette.edu'
  #     },
  #     '1' => {
  #       'id' => 'https://lafayette.edu',
  #       '_destroy' => 'true'
  #      }
  #   }
  #
  #
  class NestedAttributeFormFields < Module
    module HelperMethods
      # Converts incoming attributes hash into an array of values and removes
      # entries that include `{ '_destroy' => 'true' }` values.
      #
      # @note I believe the Resource model is responsible for casting incoming values
      #       to different classes, iirc, so we shouldn't have to worry about that here.
      #
      # @param [Hash] options
      # @option [#to_s] field
      # @option [String] value_key (used by incoming attributes, defaults to 'id')
      # @return [Array<String>]
      def parse_attribute_values(field:, value_key: 'id')
        attribute_values = send(:"#{field}_attributes")
        return if attribute_values.blank?

        adds = []
        deletes = []

        attribute_values.each do |(_idx, attrs)|
          if attrs['_destroy'] == 'true'
            deletes << attrs[value_key]
          else
            adds << attrs[value_key]
          end
        end

        (adds - deletes).uniq
      end

      def set_attributes_for(field)
        attributes = wrap_attribute_values(field: field)
        send(:"#{field}_attributes=", attributes)
      end

      def wrap_attribute_values(field:, value_key: 'id')
        Array.wrap(send(field)).each_with_index.reduce({}) do |out, (val, idx)|
          out[idx.to_s] = { value_key => val.to_s }
          out
        end
      end

      # Valkyrie::ChangeSet includes Reform::Form::ActiveModel::FormBuilderMethods
      # which has behavior that will mutate incoming form params so that *_attributes
      # values are copied to their respective field. Since we're adding our own handling
      # for *_attributes _after_ the initial form fields are being defined, calls to
      # `send(field)` will result in <field>_attributes' value. By making this method
      # a no-op, we prevent this tomfoolery.
      #
      # @see https://github.com/trailblazer/reform-rails/blob/v0.2.5/lib/reform/form/active_model/form_builder_methods.rb#L37-L46
      def rename_nested_param_for!(_params, _dfn); end
    end

    def initialize(fields)
      @fields = fields
    end

    private

    def rename_nested_param_for!(**); end

    def included(descendant)
      super

      descendant.include(HelperMethods)

      @fields.map(&:to_sym).each do |field|
        descendant.define_method(:"#{field}_populator") do |fragment:, **|
          adds = []
          deletes = []

          fragment.each do |_idx, attrs|
            if attrs['_destroy'] == 'true'
              deletes << attrs['id']
            else
              adds << attrs['id']
            end
          end

          combined_values = ((Array.wrap(send(field)).map(&:to_s) + adds) - deletes).uniq
          send(:"#{field}=", combined_values)
        end

        descendant.property(:"#{field}_attributes",
                            virtual: true,
                            prepopulator: ->(_opts) { set_attributes_for(field) },
                            populator: :"#{field}_populator")
      end
    end
  end
end
