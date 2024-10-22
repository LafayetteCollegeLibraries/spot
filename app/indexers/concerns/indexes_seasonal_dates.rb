# frozen_string_literal: true
module IndexesSeasonalDates
  extend ActiveSupport::Concern

  included do
    class_attribute :seasonal_date_field, default: 'english_language_date_teim'
    class_attribute :date_property_for_seasonal_label, default: :date_issued
  end

  def to_solr
    super.tap do |document|
      add_english_language_dates(document)
    end
  end

  def add_english_language_dates(doc)
    doc[seasonal_date_field] = dates.map do |date|
      begin
        parsed = Date.parse(date)
      rescue ArgumentError
        next unless date.match?(/^\d{4}-\d{2}/)
        parsed = Date.new(*date.split('-').map(&:to_i))
      end

      season_names_for_date(parsed) + spelled_out_for_date(parsed)
    end.flatten.reject(&:blank?)
  end

  # Determines the season based on the month:#
  #   Spring => March, April, May
  #   Summer => June, July, August
  #   Autumn/Fall => September, October, November
  #   Winter => December, January, February
  #
  # @param date [#strftime, #year]
  # @return [Array<String>]
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
  #   spelled_out_dates_for_date(Date.parse('2019-02-08'))
  #   => ['February 8 2019', 'Feb 8 2019']
  #
  # @param date [#strftime]
  # @return [Array<String>]
  def spelled_out_for_date(date)
    %w[%B %b].map { |month| date.strftime("#{month} %Y") }
  end

  # Saves us the hassle of having to type out that long attribute
  #
  # @return [Array<String>]
  def dates
    object.send(date_property_for_seasonal_label)
  end
end
