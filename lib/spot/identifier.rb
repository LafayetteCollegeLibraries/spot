# frozen_string_literal: true

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
      return new(nil, string_value) unless string_value =~ %r(#{SEPARATOR})

      prefix, *the_rest = string_value.split(SEPARATOR)
      new(prefix, the_rest.join(SEPARATOR))
    end

    # @return [Array<String>]
    def self.prefixes
      [DOI, HANDLE, ISBN, ISSN, LOCAL]
    end

    def initialize(prefix, value)
      @prefix = prefix || nil
      @value = value
    end

    def to_s
      if prefix.nil?
        value
      else
        "#{prefix}#{SEPARATOR}#{value}"
      end
    end
    alias_method :to_string, :to_s
  end
end
