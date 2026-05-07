# frozen_string_literal: true
class PublicationResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:publication_metadata)
  include Hyrax::Indexer(:institutional_metadata)

  self.sortable_date_field = :date_issued
  self.years_encompassed_fields = [:date_issued]

  def to_solr
    super.tap do |solr_doc|
      solr_doc['english_language_date_teim'] = parsed_english_language_dates

      # @todo how are we handling full-text extraction/searching?
      # solr_doc['extracted_text_tsimv'] = object.file_sets.map { |fs| fs.extracted_text.present? ? fs.extracted_text.content.strip : '' }
    end
  end

  private

  # Parses values in :date_issued and converts them to:
  #   - (Spring|Summer|Autumn/Fall|Winter) YYYY
  #   - Month YYYY
  #   - Mo YYYY
  #
  # @example for a resource with :date_issued February 11, 1986
  #  #=> ['Winter 1986', 'February 1986', 'Feb 1986']
  #
  # @example for a resource with :date_issued October 21, 2023
  #  #=> ['Autumn 2023', 'Fall 2023', 'October 2023', 'Oct 2023']
  #
  def parsed_english_language_dates
    (resource.try(:date_issued) || []).map do |date|
      begin
        parsed = Date.parse(date)
      rescue ArgumentError
        next unless date.to_s.match?(/^\d{4}-\d{2}/)
        parsed = Date.new(*date.to_s.split('-').map(&:to_i))
      end

      season_names_for_date(parsed) + full_and_abbreviated_months_for_date(parsed)
    end.flatten.uniq
  end

  # Determines the season based on the month:
  #   Spring => March, April, May
  #   Summer => June, July, August
  #   Autumn/Fall => September, October, November
  #   Winter => December, January, February
  def season_names_for_date(date)
    seasons = case date.strftime('%-m').to_i
              when 3..5 then  %w[Spring]
              when 6..8 then  %w[Summer]
              when 9..11 then %w[Autumn Fall]
              else %w[Winter]
              end
    year = date.year
    seasons.map { |season| "#{season} #{year}" }
  end

  # Transforms our date into English-language dates.
  #
  # @example
  #   full_and_abbreviated_months_for_date(Date.parse('2019-02-08'))
  #   #=> ['February 8 2019', 'Feb 8 2019']
  def full_and_abbreviated_months_for_date(date)
    %w[%B %b].map { |month| date.strftime("#{month} %Y") }
  end
end