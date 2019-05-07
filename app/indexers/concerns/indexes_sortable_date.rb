# frozen_string_literal: true
#
# Adds a +date_issued_sort_dtsi+ field to the Solr document, allowing sorting
# by the +date_issued+ property. If that property is missing, it falls back
# to the object's +create_date+. If multiple dates are provided, it choses the
# earlier date. (Note: the last choice can absolutely be altered if need be).
#
# @example
#
#    class PostcardIndexer < Hyrax::WorkIndexer
#      # ... the other includes
#      include IndexesSortableDate
#    end
#
#    indexer = PostcardIndexer.new(Postcard.new(date_issued: ['1991-09-04']))
#    solr_doc = indexer.generate_solr_document
#    puts solr_doc['date_issued_sort_dtsi']
#    # => '1991-09-04T00:00:00Z'
#
module IndexesSortableDate
  # @return [Hash<String => *>]
  def generate_solr_document
    super.tap do |doc|
      doc['date_issued_sort_dtsi'] = parse_sortable_date if date_exist? && date_matches_pattern?
      doc['date_issued_sort_dtsi'] ||= object.create_date
    end
  end

  private

    # Does the +date_issued+ property have values?
    #
    # @return [true, false]
    def date_exist?
      object.date_issued.present?
    end

    # Does our date_value match the pattern of YYYY(-MM(-DD))?
    #
    # @return [true, false]
    def date_matches_pattern?
      date_value.match?(/^\d{4}(-\d{2}(-\d{2})?)?/)
    end

    # The value we're working with. Abstracted here in the event that
    # we want to change which value gets priority.
    #
    # @return [String, nil]
    def date_value
      object.date_issued.sort.first
    end

    # Converts whatever our +date_value+ is to a YYYY-MM-DDT00:00:00Z
    # string for Solr to use in sorting.
    #
    # @return [String]
    def parse_sortable_date
      date_array = date_value.gsub(/T.*$/, '').split('-').map(&:to_i)
      Date.new(*date_array).strftime('%FT%TZ')
    end
end
