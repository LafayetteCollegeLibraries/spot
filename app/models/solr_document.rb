# frozen_string_literal: true
#
# Generated from +rails generate hyrax:install+
class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # adds our base attributes
  include Spot::SolrDocumentAttributes

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.
  use_extension(Hydra::ContentNegotiation)

  # A mapping hash of DC fields (keys) to their Solr document counterparts (values).
  # Values can be strings or arrays of strings (for concatenating multiple fields).
  #
  # @return [Hash<Symbol => String, Array<String>>]
  # @todo PA Digital wants identifiers, permalinks, and thumbnail links to all be
  #       mapped to dc:identifier. Will this just work out of the box?
  # @todo PA Digital guidelines specify ISO 639-3 for language (we're using 639-1);
  #       will we need to revisit that?
  # rubocop:disable Metrics/MethodLength
  def self.field_semantics
    {
      alternative: 'title_alternative_tesim',
      contributor: 'contributor_tesim',
      coverage: 'location_label_ssim',
      creator: 'creator_tesim',
      date: ['date_ssim', 'date_issued_ssim'],
      description: 'description_tesim',
      extent: 'original_item_extent',
      format: 'file_format_ssim',
      identifier: ['id', 'permalink_ss', 'thumbnail_url_ss'],
      isPartOf: 'member_of_collections_ssim',
      language: 'language_ssim',
      publisher: 'publisher_tesim',
      rights: 'rights_statement_ssim',
      source: 'source_tesim',
      spatial: 'location_label_ssim',
      subject: 'subject_label_ssim',
      title: 'title_tesim',
      type: 'resource_type_tesim'
    }
  end
  # rubocop:enable Metrics/MethodLength

  def sets
    Spot::OaiCollectionSolrSet.sets_for(self)
  end

  # Overrides +Hyrax::SolrDocumentBehavior#to_param+ by preferring collection slugs
  # (where present).
  #
  # @return [String]
  def to_param
    return collection_slug if collection? && collection_slug.present?
    super
  end
end
