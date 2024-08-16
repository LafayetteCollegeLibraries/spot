# frozen_string_literal: true
class AudioVisual < ActiveFedora::Base
  include Spot::WorkBehavior

  self.indexer = AudioVisualIndexer

  property :date, predicate: ::RDF::Vocab::DC.date do |index|
    index.as :symbol
  end

  property :premade_derivatives, predicate: ::RDF::URI.new('http://ldr.lafayette.edu/ns#premade_derivatives') do |index|
    index.as :symbol
  end

  property :stored_derivatives, predicate: ::RDF::URI.new('http://ldr.lafayette.edu/ns#stored_derivatives') do |index|
    index.as :symbol
  end

  def validate_resource_type?
    false
  end

  # see {Spot::WorkBehavior.setup_nested_attributes!}
  setup_nested_attributes!
end
