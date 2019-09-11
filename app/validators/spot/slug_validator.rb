# frozen_string_literal: true
module Spot
  # The rules of the road for slugs:
  # - only one allowed
  # - only alphanumeric characters and hyphens
  class SlugValidator < ActiveModel::Validator
    # @param [ActiveFedora::Base] record
    # @return [void]
    def validate(record)
      Array.wrap(options[:fields]).each do |field|
        next unless record.respond_to?(field)

        slugs = record.send(field).select { |id| id.start_with? 'slug:' }
        next if slugs.empty?

        record.errors[field] << single_slug_message unless slugs.size == 1
        record.errors[field] << slug_regex_message unless slug_valid?(slugs.first)
      end
    end

    private

      # @return [true, false]
      def slug_valid?(slug)
        slug.match?(/^slug\:[a-z0-9\-]+$/)
      end

      # @return [String]
      def single_slug_message
        "Collections may only have one 'slug' identifier"
      end

      # @return [String]
      def slug_regex_message
        "Slugs may only contain lower-case letters, numbers, and hyphens"
      end
  end
end
