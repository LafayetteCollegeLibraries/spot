# frozen_string_literal: true
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

  # @return [RDF::Reader]
  def reader
    @reader ||= RDF::Reader.for(:ntriples)
  end

  # @return [RDF::Writer]
  def writer
    @writer ||= RDF::Writer.for(:ntriples).new
  end
end
