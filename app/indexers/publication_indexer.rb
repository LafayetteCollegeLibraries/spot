# frozen_string_literal: true
class PublicationIndexer < BaseIndexer
  include IndexesEnglishLanguageDates
  include IndexesSortableDate

  self.sortable_date_property = :date_issued

  # @return [Hash]
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['license_tsm'] = object.license unless object.license.blank?

      store_full_text_content(solr_doc)
      store_years_encompassed(solr_doc)
    end
  end

  private

    # Store the full text content of all the contained file-sets
    #
    # @param [SolrDocument] doc
    # @return [void]
    def store_full_text_content(doc)
      doc['extracted_text_tsimv'] = object.file_sets.map do |fs|
        fs.extracted_text.present? ? fs.extracted_text.content.strip : ''
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
