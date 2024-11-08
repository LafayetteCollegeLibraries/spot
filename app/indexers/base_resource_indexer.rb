# frozen_string_literal: true
class BaseResourceIndexer < ::Hyrax::ValkyrieWorkIndexer
  # @note :core_metadata is included with Hyrax::ValkyrieWorkIndexer
  include Hyrax::Indexer(:base_metadata)
  include IndexesPermalinkUrl

  class_attribute :sortable_date_property, default: :date_issued

  def to_solr
    super.tap do |document|
      document['title_sort_si'] = resource.title.first.to_s.downcase
      document['date_sort_dtsi'] = generate_sortable_date
      document['identifier_standard_ssim'] = mapped_identifiers.select(&:standard?).map(&:to_s)
      document['identifier_local_ssim'] = mapped_identifiers.select(&:local?).map(&:to_s)

      document['language_ssim'] = resource.try(:language)
      document['language_label_ssim'] = (resource.try(:language) || []).map { |language| Spot::ISO6391.label_for(language) }
      document['thumbnail_url_ss'] = index_thumbnail_url

      # @todo not sure if the resource retains file_set objects anymore? there is no longer
      #       a :file_sets method and the closest analogue I can find in Hyrax 3.6 is :member_ids,
      #       which would require us to fetch the objects just to copy the mime_type to the
      #       parent work. maybe it would be better to give this to the presenter and delegate
      #       to the file_set_presenters?
      #
      # document['file_format_ssim'] = resource.file_sets.map(&:mime_type).reject(&:blank?)

      stringify_rdf_uris(document)
    end
  end

  private

  # @todo maybe this is fixed down the road in Hyrax, but Hyrax::Indexer(:base_metadata)
  #       will index fields with `document[field] = resource.send(field)` which will lead
  #       to (at the very least) RDF::URI values on the way to Solr. I'm not sure if there
  #       are mechanisms in place in Hyrax/RSolr to stringify URI values before they get
  #       sent to Solr, but just in case they're not we'll at least stringify RDF::URIs.
  def stringify_rdf_uris(document)
    document.each do |key, value|
      next unless value.is_a?(Array) && value.any?(RDF::URI)
      document[key] = value.map(&:to_s) # should we _just_ be targeting URIs?
    end
  end

  def generate_sortable_date
    object_date_values = resource.try(sortable_date_property) || []
    date_value = object_date_values.sort.first
    output_format_string = '%FT%TZ'

    # if the object doesn't have any date values, default to using
    # its created_at value (note: this will return nil if the object
    # doesn't have a :created_at value, typically assigned on persistence.
    return resource.try(:created_at).try(:strftime, output_format_string) if date_value.nil?

    parsed = Date.edtf(date_value)
    parsed.strftime(output_format_string) if parsed.present?
  end

  def index_thumbnail_url
    return if ENV['URL_HOST'].blank?

    host = ENV['URL_HOST']
    host = "https://#{host}" unless host.start_with?('http')
    path = Hyrax::ThumbnailPathService.call(resource)
    URI.join(host, path).to_s
  end

  def mapped_identifiers
    @mapped_identifiers ||= (resource&.identifier || []).map { |id| Spot::Identifier.from_string(id) }
  end
end
