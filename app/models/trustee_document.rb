class TrusteeDocument < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validate :pages_must_be_integers_or_nil

  self.indexer = TrusteeDocumentIndexer

  self.human_readable_type = 'Trustee Document'

  property :page_start, predicate: ::RDF::Vocab::MODS.partStart, multiple: false do |index|
    index.type :integer
    index.as :stored_searchable
  end

  property :page_end, predicate: ::RDF::Vocab::MODS.partEnd, multiple: false do |index|
    index.type :integer
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  private

  def pages_must_be_integers_or_nil
    validate_integerality_of(:page_start)
    validate_integerality_of(:page_end)
  end

  def validate_integerality_of(field)
    value = self.send(field)
    return if value.blank? || value.is_a?(Integer)

    errors.add(field, 'must be an integer')
  end
end
