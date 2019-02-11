# frozen_string_literal: true
class PublicationIndexer < Hyrax::WorkIndexer
  include IndexesRightsStatements
  include IndexesEnglishLanguageDates

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
      store_license(solr_doc)
      store_language_label(solr_doc)
      store_years_encompassed(solr_doc)
    end
  end

  private

    # we're storing licenses but not indexing them
    #
    # @param [SolrDocument] doc
    # @return [void]
    def store_license(doc)
      doc['license_tsm'] = object.license
    end

    # @param [SolrDocument] doc
    # @return [void]
    def store_language_label(doc)
      label_key = 'language_label_ssim'
      doc[label_key] ||= []

      object.language.map do |lang|
        doc[label_key] << Spot::ISO6391.label_for(lang) || lang
      end
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
