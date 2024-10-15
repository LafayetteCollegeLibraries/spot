class BaseResourceIndexer < ::Hyrax::ValkyrieIndexer
  include IndexesPermalinkUrl
  include IndexesSeasonalDates

  class_attribute :sortable_date_property, default: :date_issued

  def to_solr
    super.tap do |document|
      document['title_sort_si'] = resource.title.first.to_s.downcase
      document['date_sort_dtsi'] = generate_sortable_date
      document['file_format_ssim'] = resource.file_sets.map(&:mime_type).reject(&:blank?)
      document['identifier_standard_ssim'] = mapped_identifiers.select(&:standard?).map(&:to_s)
      document['identifier_local_ssim'] = mapped_identifiers.select(&:local?).map(&:to_s)

      index_language_and_label(document)
      index_sortable_date(document)
      index_thumbnail_url(document)
    end
  end

  private

  def generate_sortable_date
    raw_date_value = (resource.try(sortable_date_property) || []).sort.first
    parsed = Date.edtf(raw)

    return Date.parse(resource.create_date.to_s).strftime('%FT%TZ') if parsed.nil?

    # if we get an edtf range/set/etc, we want the earliest date.
    # rather than checking if it's a +EDTF::Set+, +EDTF::Interval+, etc.
    # we'll see if it's inherited from +Enumerable+ and call +#first+ if so
    parsed = parsed.first if parsed.class < ::Enumerable
    parsed.strftime('%FT%TZ')
  end

  def index_language_and_label(solr_document)
    return if resource&.language.blank?

    solr_document['language_ssim'] ||= []
    solr_document['language_label_ssim'] ||= []

    resource.language.each do |lang|
      solr_document['language_ssim'] << lang
      solr_document['language_label_ssim'] << Spot::ISO6391.label_for(lang)
    end
  end

  def index_thumbnail_url(solr_document)
    return if ENV['URL_HOST'].blank?

    host = ENV['URL_HOST']
    host = "http://#{host}" unless host.start_with?('http')
    path = Hyrax::ThumnailPathService.call(resource) # @todo does this work with resources?
    url = URI.join(host, path).to_s

    solr_document['thumbnail_url_ss'] = url unless url.empty?
  end

  def mapped_identifiers
    @mapped_identifiers ||= (resource&.identifier || []).map { |id| Spot::Identifier.from_string(id) }
  end
end