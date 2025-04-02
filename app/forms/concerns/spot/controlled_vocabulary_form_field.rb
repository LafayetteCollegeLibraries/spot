# frozen_string_literal: true
module Spot
  # Mixin to add support for Controlled Vocabulary fields in Resource forms.
  #
  # @usage
  #   class CoolNewResourceForm < Hyrax::Forms::ResourceForm(CoolNewResource)
  #     include Hyrax::FormFields(:base_metadata)
  #     include Hyrax::FormFields(:cool_new_resource_metadata)
  #     include Spot::ControlledVocabularyFormField(:academic_department)
  #     include Spot::ControlledVocabularyFormField(:subject, vocabulary_class: Spot::ControlledVocabularies::AssignFastSubject)
  #
  #     # ...
  #   end
  #
  # Similarly to `Spot::LanguageTaggedFormFields`, this creates a virtual `<field>_attributes` property that
  # is parsed downstream by `ControlledVocabularyInput` and its descendants into a Select2 typeahead input.
  # For local controlled vocabularies (eg. Language, Academic Departments, Subject OCM) the values are simply
  # cast as strings, but for remote authorities (eg. Subject, Location), we need to wrap URI values in an
  # `ActiveTriples::Resource` class to fetch values. This was previously configured in ActiveFedora within the
  # model's property via a `:class_name attribute, but for now we'll definie it in the form instead of the model.
  #
  # @todo Maybe this behavior _should_ be defined within the model? Not sure how you'd cast an empty value in the
  #       form, though. Maybe configured in two places? (redundancy?)
  def self.ControlledVocabularyFormField(field, vocabulary_class: String)
    ControlledVocabularyFormField.new(field, vocabulary_class: vocabulary_class)
  end

  class ControlledVocabularyFormField < Module
    def initialize(field, vocabulary_class: String)
      @field = field
      @vocabulary_class = vocabulary_class
    end

    private

    def included(descendant)
      super

      descendant.include(HelperMethods)

      field = @field.to_s
      attributes_key = "#{field}_attributes".to_sym
      prepopulator_key = "#{field}_prepopulator".to_sym
      populator_key = "#{field}_populator".to_sym

      descendant.define_method(prepopulator_key) do
        vocab_class = @vocabulary_class || String
        send(:"#{attributes_key}=", wrap_attribute_values(field: field, field_value_class: vocab_class))
      end

      descendant.define_method(populator_key) do |fragment:, **|
        send(:"#{field}=", parse_attribute_fragment(fragment: fragment, field: field))
      end

      descendant.property(attributes_key, virtual: true, prepopulator: prepopulator_key, populator: populator_key)
    end

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

      # @option [Symbol,String] field
      # @option [String] value_key (default: 'id')
      # @return [Hash<String => Hash<String => String>>]
      def wrap_attribute_values(field:, field_value_class: String)
        values = Array.wrap(send(field)).map { |v| v.is_a?(field_value_class) ? v : field_value_class.new(v) }
        values << field_value_class.new if values.empty?
        values
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
  end
end
