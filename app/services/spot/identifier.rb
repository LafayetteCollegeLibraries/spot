# frozen_string_literal: true

# A utility class to handle identifiers in a uniform way.
#
# @todo: are the prefixes something we want/need hardcoded? or should this
#        be moved to an ActiveRecord model that's seeded?
module Spot
  class Identifier
    attr_reader :prefix, :value

    SEPARATOR = ':'

    DOI = 'doi'
    HANDLE = 'hdl'
    ISBN = 'isbn'
    ISSN = 'issn'
    LOCAL = 'lafayette'

    # @param [String] string_value
    # @return [Spot::Identifier]
    def self.from_string(string_value)
      return new(nil, string_value) unless string_value.match?(%r{#{SEPARATOR}})

      prefix, *the_rest = string_value.split(SEPARATOR)
      prefix.downcase!

      return new(nil, string_value) unless prefixes.include?(prefix)

      new(prefix, the_rest.join(SEPARATOR))
    end

    # @return [Array<String>]
    def self.prefixes
      [DOI, HANDLE, ISBN, ISSN, LOCAL]
    end

    # @return [String]
    def self.prefix_label(prefix)
      I18n.t("spot.identifiers.labels.#{prefix}", default: prefix) unless prefix.nil?
    end

    def initialize(prefix, value)
      @prefix = prefix
      @value = value
    end

    # @return [String]
    def prefix_label
      self.class.prefix_label(prefix)
    end

    # @return [String]
    def to_s
      if value.blank?
        ''
      elsif prefix.blank?
        value
      else
        "#{prefix}#{SEPARATOR}#{value}"
      end
    end
    alias to_string to_s
  end
end
