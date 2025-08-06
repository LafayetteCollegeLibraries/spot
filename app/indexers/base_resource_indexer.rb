# frozen_string_literal: true
#
# Indexer used as a base for all of our Resource objects. Extend the #to_solr
# method using +super.tap+ to define fields specific to the resource.
#
# Subclasses should define the +sortable_date_property+ attribute to index
# a sortable date (resources have different primary date fields).
#
# @example
#   class CoolResourceIndexer < BaseResourceIndexer
#     include Hyrax::Indexer(:cool_metadata)
#     self.sortable_date_property = :date_issued
#
#     def to_solr
#       super.tap do |document|
#         document['some_metadata_field_ssim'] = resource.try(:metadata_field)
#       end
#     end
#   end
#
class BaseResourceIndexer < ::Hyrax::ValkyrieWorkIndexer
  # @note :core_metadata is included with Hyrax::ValkyrieWorkIndexer
  include Hyrax::Indexer(:base_metadata)
  include Spot::IndexesPermalinkUrl
  include Spot::IndexesRightsStatementsAndLabels
  include Spot::RemoteLabelIndexing

  class_attribute :sortable_date_property, default: :date

  def to_solr
    super.tap do |document|
      document['title_sort_si'] = generate_sortable_title
      document['date_sort_dtsi'] = generate_sortable_date
      document['identifier_standard_ssim'] = wrapped_identifiers.select(&:standard?).map(&:to_s)
      document['identifier_local_ssim'] = wrapped_identifiers.select(&:local?).map(&:to_s)
      document['thumbnail_url_ss'] = index_thumbnail_url
      document['file_format_ssim'] = file_set_mime_types

      fetch_and_attach_remote_labels_to(document,
                                        field: :language,
                                        controlled_vocabulary_class: Spot::Iso6391)
      fetch_and_attach_remote_labels_to(document,
                                        field: :location,
                                        controlled_vocabulary_class: Spot::ControlledVocabularies::Location,
                                        label_key: ['location_label_ssim', 'location_label_tesim'])
      fetch_and_attach_remote_labels_to(document,
                                        field: :subject,
                                        controlled_vocabulary_class: Spot::ControlledVocabularies::AssignFastSubject,
                                        label_key: ['subject_label_ssim', 'subject_label_tesim'])

      add_citation_metadata(document) if resource.try(:bibliographic_citation).present?

      # @note run this last
      stringify_rdf_uris(document)
    end
  end

  private

  # Previously was a mixin (IndexesCitationMetadata); parses the first :bibliographic_citation
  # value and adds the metadata to the Solr document.
  #
  # @param [SolrDocument,Hash]
  # @return [void]
  def add_citation_metadata(document)
    raw = Array.wrap(resource.bibliographic_citation).first
    citation = ::AnyStyle.parse(raw)&.first
    return if citation.blank? || citation[:type].nil?

    document['citation_journal_title_ss'] = citation[:"container-title"]&.first
    document['citation_volume_ss'] = citation[:volume]&.first
    document['citation_issue_ss'] = citation[:issue]&.first

    # split pages on any type of hyphen (*waves fist at em and en dashes*)
    first_page, last_page = citation[:pages]&.first&.split(/[-–—]/, 2)
    document['citation_firstpage_ss'] = first_page
    document['citation_lastpage_ss'] = last_page
  end

  # Should come up empty for new works before files are attached, but otherwise returns
  # the mime_types of all child file_sets.
  #
  # @return [Array<String>]
  def file_set_mime_types
    file_sets = Hyrax.query_service.custom_queries.find_child_file_sets(resource: resource)
    file_sets.map { |fs| Hyrax::FileSetTypeService.new(file_set: fs).mime_type }
  end

  # Uses a) earliest date in +sortable_date_property+, b) resource's :created_at value to serve
  # as the sort date for the object. Will return nil if neither of these are present.
  #
  # @return [String, nil]
  def generate_sortable_date
    object_date_value = resource.try(sortable_date_property).presence || resource.try(:created_at).try(:strftime, '%FT%TZ')
    date_value = Array.wrap(object_date_value).sort.first

    Date.edtf(date_value).try(:strftime, '%FT%TZ')
  end

  # @return [String]
  def generate_sortable_title
    resource.title.first.to_s.downcase.gsub(/^(an?|the)\s+/, '').strip
  end

  def index_thumbnail_url
    return if ENV['URL_HOST'].blank?

    host = ENV['URL_HOST']
    host = "https://#{host}" unless host.start_with?('http')
    path = Hyrax::ThumbnailPathService.call(resource)
    URI.join(host, path).to_s
  end

  def wrapped_identifiers
    @wrapped_identifiers ||= (resource.try(:identifier) || []).map { |id| Spot::Identifier.from_string(id) }
  end

  # @todo maybe this is fixed down the road in Hyrax, but Hyrax::Indexer(:base_metadata)
  #       will index fields with `document[field] = resource.send(field)` which will lead
  #       to (at the very least) RDF::URI values on the way to Solr. I'm not sure if there
  #       are mechanisms in place in Hyrax/RSolr to stringify URI values before they get
  #       sent to Solr, but just in case they're not we'll at least stringify RDF::URIs.
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
