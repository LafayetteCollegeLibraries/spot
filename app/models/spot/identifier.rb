# frozen_string_literal: true
#
# A utility class to handle identifiers in a uniform way.
# We're considering a "standard" identifier to be one that
# belongs to an external service. For now, adding to the
# list of standardized identifiers requires adding the prefix
# to the +.standard_prefixes+ array. This may change in the future.
#
# @example Parsing a "standard" identifier from a string
#
#   id = Spot::Identifier.from_string('isbn:9783908247692')
#   id.prefix
#   # => 'isbn'
#   id.value
#   # => '9783908247692'
#   id.standard?
#   # true
#
# @example Parsing a non-standard identifier
#
#   id = Spot::Identifier.from_string('lafayette_magazine:123')
#   id.prefix
#   # => 'lafayette_magazine'
#   id.value
#   # => '123'
#   id.standard?
#   # => false
#
# @example Getting the label for an identifier's prefix (when known)
#
#   id = Spot::Identifier.prefix_label('hdl:1234/5678')
#   # => 'Handle'
#
module Spot
  class Identifier
    attr_reader :prefix, :value

    SEPARATOR = ':'

    DOI = 'doi'
    HANDLE = 'hdl'
    ISBN = 'isbn'
    ISSN = 'issn'
    OCLC = 'oclc'

    class << self
      # @param [String] string_value
      # @return [Spot::Identifier]
      def from_string(string_value)
        return new(nil, string_value) unless string_value.include?(SEPARATOR)

        prefix, id = string_value.split(SEPARATOR, 2)
        new(prefix.downcase, id)
      end

      # @param [String] prefix
      # @param [String] :default The fallback for the label
      # @return [String]
      def prefix_label(prefix, default: prefix.titleize)
        I18n.t("spot.identifiers.labels.#{prefix}", default: default) unless prefix.nil?
      end

      # @return [Array<String>]
      def standard_prefixes
        [DOI, HANDLE, ISBN, ISSN, OCLC]
      end
    end

    # @param [String] prefix
    # @param [String] value
    def initialize(prefix, value)
      @prefix = prefix
      @value = value
    end

    # @return [true, false]
    def local?
      !standard?
    end

    # @return [String]
    def prefix_label
      self.class.prefix_label(prefix, default: prefix.titleize)
    end

    # @return [true, false]
    def standard?
      self.class.standard_prefixes.include?(prefix)
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
