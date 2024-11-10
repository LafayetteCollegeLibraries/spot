# frozen_string_literal: true
require 'rdf/ntriples'

# Helper class to serialize RDF literal values.
#
# @example
#   RdfLiteralSerializer.serialize(RDF::Literal.new('Cool Beans', language: :eng))
#   # => "\"Cool Beans\"@eng"
#
# @example
#   RdfLiteralSerializer.deserialize('"Cool Beans"@eng')
#   # => #<RDF::Literal:0xa6874("Cool Beans"@eng)>
#
# @todo Move this into Spot namespace?
# @todo Support for types other than :ntriples? :ttl fails to parse, for example
#       (NoMethodError for 'parse_literal' in the Turtle reader)
class RdfLiteralSerializer
  include Singleton

  class_attribute :type, default: :ntriples

  # @param [RDF::Literal] literal
  # @return [String]
  def self.serialize(literal)
    instance.writer.format_literal(literal)
  end

  # @param [String] input_string
  # @return [RDF::Literal]
  def self.deserialize(input_string)
    instance.reader.parse_literal(input_string)
  end

  # @return [RDF::Reader]
  def reader
    RDF::Reader.for(type)
  end

  # @return [RDF::Writer]
  def writer
    RDF::Writer.for(type).new
  end
end
