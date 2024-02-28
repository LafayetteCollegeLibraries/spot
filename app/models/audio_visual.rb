# frozen_string_literal: true
class AudioVisual < ActiveFedora::Base
  include Spot::WorkBehavior

  self.indexer = AudioVisualIndexer

  property :date, predicate: ::RDF::Vocab::DC.date do |index|
    index.as :symbol
  end

  def validate_resource_type?
    false
  end
end
