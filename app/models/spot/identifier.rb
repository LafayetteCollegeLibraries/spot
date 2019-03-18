# frozen_string_literal: true
#
# A utility class to handle identifiers in a uniform way.
# We're considering a "standard" identifier to be one that
# belongs to an external service. But really, any prefix
# that is passed to {.register_prefix} is considered "standard".
#
# @example Registering a prefix
#
#   Spot::Identifier.register_prefix('hdl')
#   Spot::Identifier.from_string('hdl:1234/5678').standard?
#   # => true
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
    class_attribute :prefix_registry
    self.prefix_registry = Set.new

    attr_reader :prefix, :value

    SEPARATOR = ':'

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

      # @param [String] prefix
      # @return [void]
      def register_prefix(prefix)
        prefix_registry << prefix.to_s
      end

      # Legacy method used in the UI that might be worth keeping around.
      # Returns all of the registered prefixes
      #
      # @return [Array<String>]
      def standard_prefixes
        prefix_registry.to_a
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
      prefix_registry.include?(prefix)
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
