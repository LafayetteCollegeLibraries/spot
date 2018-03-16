# Generated via
#  `rails generate hyrax:work Trustee::Document`
class Trustee::Document < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates_numericality_of :start_page, allow_nil: true
  validates_numericality_of :end_page, allow_nil: true

  self.indexer = Trustee::DocumentIndexer

  self.human_readable_type = 'Trustee Document'

  property :start_page, predicate: ::RDF::Vocab::MODS.partStart, multiple: false do |index|
    index.type :integer
    index.as :stored_sortable
  end

  property :end_page, predicate: ::RDF::Vocab::MODS.partEnd, multiple: false do |index|
    index.type :integer
    index.as :stored_sortable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
