# frozen_string_literal: true
#
# Mixin to remove whitespace from form param fields when calling +.model_attributes+
module StripsWhitespace
  extend ActiveSupport::Concern

  module ClassMethods
    # @param [ActionController::Parameters, Hash] form_params
    # @return [Hash<Symbol => Array<String>>]
    def model_attributes(form_params)
      super.tap do |params|
        terms.each do |key|
          if params[key].is_a? Array
            params[key] = params[key].map { |v| v.respond_to?(:strip) ? v.strip : v }.reject(&:blank?)
          elsif params[key].is_a? String
            params[key] = params[key].strip
          end
        end
      end
    end
  end
end
