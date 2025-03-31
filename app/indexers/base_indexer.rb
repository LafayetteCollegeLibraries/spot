# frozen_string_literal: true
#
# Base indexing behavior to be inherited by new work models. This ought to
# help prevent having to include the same mixins over and over.
class BaseIndexer < ::Hyrax::WorkIndexer
  include IndexesLanguageAndLabel
  include IndexesPermalink
  include IndexesRightsStatements
  include IndexesSortableDate
  include IndexesCitationMetadata

  # Overriding the default +Hyrax::DeepIndexingService+ for our own, which
  # doesn't require +Hyrax::BasicMetadata+
  #
  # @return [Class]
  def rdf_service
    Spot::DeepIndexingService
  end

  # @return [Hash<String => *>]
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_sort_si'] = object.title.first.to_s.downcase
      solr_doc['identifier_standard_ssim'] = mapped_identifiers.select(&:standard?).map(&:to_s)
      solr_doc['identifier_local_ssim'] = mapped_identifiers.select(&:local?).map(&:to_s)
      solr_doc['file_format_ssim'] = object.file_sets.map(&:mime_type).reject(&:blank?)

      store_thumbnail_url(solr_doc)
      stringify_rdf_uris(solr_doc)
    end
  end

  private

  # @return [Array<Spot::Identifier>]
  def mapped_identifiers
    @mapped_identifiers ||= object.identifier.map { |id| Spot::Identifier.from_string(id) }
  end

  # @param [SolrDocument] doc
  # @return [void]
  def store_thumbnail_url(doc)
    return if ENV['URL_HOST'].blank?

    host = ENV['URL_HOST']
    host = "http://#{host}" unless host.start_with?('http')
    path = Hyrax::ThumbnailPathService.call(object)
    url = URI.join(host, path).to_s

    doc['thumbnail_url_ss'] = url unless url.empty?
  end

  # @see app/indexers/base_resource_indexer.rb
  def stringify_rdf_uris(document)
    document.transform_values! do |values|
      stringified_values = stringify_values(values)
      values.is_a?(Array) ? stringified_values : stringified_values.first
    end
  end

  def stringify_values(values)
    Array.wrap(values).map do |value|
      case value
      when RDF::Literal, RDF::URI
        value.to_s
      when ActiveTriples::Resource
        value.rdf_subject
      else
        value
      end
    end
  end
end
