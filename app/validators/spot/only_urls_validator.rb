# frozen_string_literal: true
#
#
require 'uri'

module Spot
  class OnlyUrlsValidator < ActiveModel::Validator
    # @param record [ActiveModel::Base]
    # @return [void]
    def validate(record)
      fields.each do |field|
        next unless record.respond_to?(field)

        values = record.send(field)
        next if values.empty?

      # @todo "DEPRECATION WARNING: Calling `<<` to an ActiveModel::Errors message array in order to add an error is deprecated.
      #        Please call `ActiveModel::Errors#add` instead."
      # @see https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
        values.each do |val|
          record.errors[field] << "#{val} is not a valid URL" unless val.match?(uri_regex)
        end
      end
    end

    private

    # @return [Array<Symbol>]
    def fields
      Array(options[:fields])
    end

    # @return [Regexp]
    def uri_regex
      URI.regexp
    end
  end
end
