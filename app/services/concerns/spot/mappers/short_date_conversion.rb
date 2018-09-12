# frozen_string_literal: true

module Spot::Mappers::ShortDateConversion
  # Converts dates from mm/dd/yy to
  def short_date_to_iso(date, century_threshold: 30)
    m = date.match(%r[(?<month>\d{1,2})/(?<day>\d{1,2})/(?<year>\d{2})])

    return date if m.nil?

    year_prefix = m[:year].to_i < century_threshold ? '20' : '19'
    padded_year = m[:year].rjust(2, '0')

    year = "#{year_prefix}#{padded_year}"
    month = m[:month].rjust(2, '0')
    day = m[:day].rjust(2, '0')

    "#{year}-#{month}-#{day}"
  end
end
