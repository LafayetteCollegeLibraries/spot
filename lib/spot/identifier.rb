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
      prefix, *the_rest = string_value.split(SEPARATOR)
      new(prefix, the_rest.join(SEPARATOR))
    end

    # @return [Array<String>]
    def self.prefixes
      [DOI, HANDLE, ISBN, ISSN, LOCAL]
    end

    def initialize(prefix, value)
      @prefix = prefix
      @value = value
    end

    def doi?
      prefix == DOI
    end

    def handle?
      prefix == HANDLE
    end

    def isbn?
      prefix == ISBN
    end

    def issn?
      prefix == ISSN
    end

    def local?
      prefix == LOCAL
    end
  end
end
