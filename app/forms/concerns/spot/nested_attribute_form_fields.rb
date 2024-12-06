# frozen_string_literal: true
module Spot
  # Adds support for nested attribute fields in Hyrax forms. These fields use Select2 in the UI
  # which sends data via a hash with numbered keys pointing at URI values.
  #
  # @usage
  #   class CoolResourceForm < Hyrax::ResourceForm(CoolResource)
  #     include Hyrax::Schema(:core_metadata)
  #     include Spot::NestedAttributeFormFields(:subject, :location)
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
  def self.NestedAttributeFormFields(*fields)
    NestedAttributeFormFields.new(fields)
  end

  class NestedAttributeFormFields < Module
    module HelperMethods
      # Called from within the _attributes :populator method to parse through
      # an incoming hash and return the intended field's values — original
      # form values concated with incoming _attributes additions (see @note below)
      #
      # @params [Hash] options
      # @option [Hash] fragment (see above for incoming hash format)
      # @option [String] field
      # @return [Array<String>]
      #
      # @note I don't believe we need to cast the values that are returned, I
      #       think the Resource model will take care of that?
      #
      # @note in theory we're setting the _attributes field with the original
      #       form values on prepopulation, so we shouldn't need to including
      #       them in the output, but this is following Hyrax conventions in
      #       Hyrax::Forms::PcdmObjectForm.
      #
      # @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/forms/hyrax/forms/pcdm_object_form.rb#L31-L43
      def parse_attribute_fragment(fragment:, field:, value_key: 'id')
        adds = []
        deletes = []

        fragment.each do |_idx, attrs|
          value = attrs[value_key]
          if attrs['_destroy'] == 'true'
            deletes << value
          else
            adds << value
          end
        end

        ((Array.wrap(send(field)).map(&:to_s) + adds) - deletes).uniq
      end

      # Called from the _attributes :prepopulator method to wrap values
      # in the hash format used by the Select2 widget for controlled
      # vocabulary fields.
      #
      # @param [Hash] options
      # @option [Symbol,String] field
      # @option [String] value_key
      # @return [Hash<String => Hash<String => String>>]
      def wrap_attribute_values(field:, value_key: 'id')
        Array.wrap(send(field)).each_with_index.each_with_object({}) do |(val, idx), out|
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
      @fields = fields.map(&:to_sym)
    end

    private

    def included(descendant)
      super

      descendant.include(HelperMethods)

      @fields.each do |field|
        prepopulator = ->(_opts) { send(:"#{field}_attributes=", wrap_attribute_values(field: field)) }
        populator = ->(fragment:, **) { send(:"#{field}=", parse_attribute_fragment(fragment: fragment, field: field)) }

        descendant.property(:"#{field}_attributes",
                            virtual: true,
                            prepopulator: prepopulator,
                            populator: populator)
      end
    end
  end
end
