# frozen_string_literal: true
class AudioVisual < ActiveFedora::Base
  include Spot::WorkBehavior

  self.indexer = AudioVisualIndexer

  property :date, predicate: ::RDF::Vocab::DC.date do |index|
    index.as :symbol
  end

  # @todo is there a predicate for this?
  property :embed_url, predicate: ::RDF::URI.new('http://ldr.lafayette.edu/ns#embed_url') do |index|
    index.as :symbol
  end

  def validate_resource_type?
    false
  end
end