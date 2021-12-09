# frozen_string_literal: true
class ImageIndexer < BaseIndexer
  self.sortable_date_property = :date

  def generate_solr_document
    super.tap do |solr_doc|
      store_years_encompassed(solr_doc)
    end
  end

private

  # Gathers the values found in +#date+ and +#date_associated+, parses out the years
  # and indexes them for use with the Years Encompassed slider
  #
  # @param [SolrDocument, Hash] doc
  # @reutnr [void]
  def store_years_encompassed(doc)
    raw_values = [:date, :date_associated].map { |s| object.send(s) }.map(&:to_a).flatten
    years = raw_values.reduce([]) do |dates, date|
      parsed = Date.edtf(date)
      next (dates + [parsed.year]) if parsed.is_a? Date
      next dates if parsed.nil? || !parsed.respond_to?(:map)

      dates + parsed.map(&:year)
    end

    doc['years_encompassed_iim'] = years.sort.uniq
  end
end
