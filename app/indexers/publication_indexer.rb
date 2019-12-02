# frozen_string_literal: true
class PublicationIndexer < Hyrax::WorkIndexer
  include IndexesRightsStatements
  include IndexesEnglishLanguageDates
  include IndexesLanguageAndLabel
  include IndexesSortableDate
  include IndexesPermalink
  include IndexesIdentifiers

  # Overriding the default +Hyrax::DeepIndexingService+ for our own, which
  # doesn't require +Hyrax::BasicMetadata+
  #
  # @return [Class]
  def rdf_service
    Spot::DeepIndexingService
  end

  # @return [Hash]
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_sort_si'] = object.title.first.to_s.downcase

      store_license(solr_doc)
      store_years_encompassed(solr_doc)
      store_full_text_content(solr_doc)
      store_file_format(solr_doc)
      store_thumbnail_url(solr_doc)
    end
  end

  private

    # We want to display the mime types of the contained file_sets in our
    # OAI response.
    #
    # @param [SolrDocument] doc
    # @return [void]
    def store_file_format(doc)
      doc['file_format_ssim'] = object.file_sets.map(&:mime_type).reject(&:blank?)
    end

    # Store the full text content of all the contained file-sets
    #
    # @param [SolrDocument] doc
    # @return [void]
    def store_full_text_content(doc)
      doc['extracted_text_tsimv'] = object.file_sets.map do |fs|
        fs.extracted_text.present? ? fs.extracted_text.content.strip : ''
      end
    end

    # we're storing licenses but not indexing them
    #
    # @param [SolrDocument] doc
    # @return [void]
    def store_license(doc)
      doc['license_tsm'] = object.license
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

    # @param [SolrDocument] doc
    # @return [void]
    def store_years_encompassed(doc)
      doc['years_encompassed_iim'] = object.date_issued.map { |d| parse_year(d) }.reject(&:blank?)
    end

    # @param date [String]
    # @return [Number]
    def parse_year(date)
      DateTime.parse(d).utc.year
    rescue
      year_match = date.match(/^(\d{4})/)
      return nil if year_match.nil?

      year_match[1].to_i
    end
end
