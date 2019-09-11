# frozen_string_literal: true
#
# Mixin used to split out a work's +:identifier+ values into
# 'standard' and 'local' identifiers. In this context, a
# 'standard' identifier is one whose prefix has been registered
# (via +Spot::Identifier.register_prefix+, see +config/initializers/spot_identifier.rb+).
# This will also take care of parsing the parameters on
# form submission and convert the values back into the work's
# +:identifier+ field.
#
# To ensure that the fields appear on the form, you'll need to
# add +:standard_identifier+ and +:local_identifier+ to your
# form's +.terms+ array.
#
# @example
#   class Hyrax::WorkForm < Hyrax::Forms::WorkForm
#     include ::IdentifierFormFields
#
#     self.terms = [:title, :standard_identifier, :local_identifier]
#   end
#
module IdentifierFormFields
  extend ActiveSupport::Concern

  included do
    class_attribute :identifier_field
    self.identifier_field = :identifier
  end

  # The +HydraEditor::Form+ base initializes fields using +model.attributes+,
  # which does not include +:standard_identifier+ or +:local_identifier+.
  # This stuffs those pre-existing values in + follows the convention of
  # providing an empty-string, which gives us a starting point on the form.
  #
  # @return [void]
  protected def initialize_fields
    super.tap do
      self[:local_identifier] = local_identifier + ['']
      self[:standard_identifier] = standard_identifier + ['']
    end
  end

  # Under-the-hood we're storing NOID values as an identifier,
  # but this will hide it from the form, so we don't accidentally
  # remove the value.
  #
  # @see {Publication#ensure_noid_in_identifier}
  # @return [Array<String>]
  def local_identifier
    self[identifier_field]
      .map { |id| Spot::Identifier.from_string(id) }
      .select(&:local?)
      .reject { |id| id.prefix == 'noid' }
      .map(&:to_s)
  end

  # @return [Array<String>]
  def standard_identifier
    self[identifier_field]
      .map { |id| Spot::Identifier.from_string(id) }
      .select(&:standard?)
      .map(&:to_s)
  end

  module ClassMethods
    # Adds standard_identifier + local_identifier fields to our permitted_params
    # if they're included in the +.terms+ class_attribute. Note that the terms
    # +:standard_identifier+ and/or +:local_identifier+ must be included in the
    # form in order for them to be added to the permitted_params array.
    #
    # @return [Array<Symbol,Hash<Symbol => Array>>]
    def build_permitted_params
      super.tap do |params|
        if terms.include?(:standard_identifier)
          params << {
            standard_identifier_prefix: [],
            standard_identifier_value: []
          }
        end

        params << { local_identifier: [] } if terms.include?(:local_identifier)
      end
    end

    # Transforms the standard/local params down into the identifier field
    # for the model. +:standard_identifier+s are mapped to combine the
    # prefixes + values, +:local_identifiers+ are added as-is.
    #
    # @param [ActionController::Parameters, Hash] form_params
    # @return [ActionController::Parameters]
    def model_attributes(form_params)
      super.tap do |params|
        prefixes = Array.wrap(params.delete('standard_identifier_prefix'))
        values = Array.wrap(params.delete('standard_identifier_value'))
        locals = Array.wrap(params.delete('local_identifier'))

        mapped_std = prefixes.zip(values).map do |(prefix, value)|
          Spot::Identifier.new(prefix, value).to_s
        end.reject(&:blank?)

        params[identifier_field] ||= []
        params[identifier_field] += mapped_std
        params[identifier_field] += locals
      end
    end

    # @return [true, false]
    def multiple?(term)
      return super unless %i[standard_identifier local_identifier].include?(term.to_sym)
      true
    end
  end
end
