# frozen_string_literal: true
require 'rdf/ntriples'

class RdfLiteralSerializer
  # @return [String]
  def serialize(literal)
    writer.format_literal(literal)
  end

  # @return [RDF::Literal]
  def deserialize(string)
    reader.parse_literal(string)
  end

  private

  # @return [Symbol]
  def type
    :ntriples
  end

  # @return [RDF::Reader]
  def reader
    @reader ||= RDF::Reader.for(type)
  end

  # @return [RDF::Writer]
  def writer
    @writer ||= RDF::Writer.for(type).new
  end
end
