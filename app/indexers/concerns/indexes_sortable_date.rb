# frozen_string_literal: true
#
# Adds a sortable date field to the Solr document using
# a configurable class attribute. If no value is found,
# we'll default to the object's create_date property
# (used by Fedora).
#
# Note: this uses the +Date.edtf+ parser, so EDTF values
# are valid and will round-down to the lowest value
# ('2019-12' will become '2019-12-01T00:00:00Z'; see example).
#
# @example
#   class Book < ActiveFedora::Base
#     property :date_issued, predicate: ::RDF::Vocab::DC.issued
#   end
#
#   class BookIndexer < BaseIndexer
#     include IndexesSortableDate
#
#     self.sortable_date_property = :date_issued
#   end
#
#   book = Book.find('abc123def')
#   book.date_issued
#   # => ['2019-12']
#   indexer = BookIndexer.new(book)
#   solr_doc = indexer.generate_solr_document
#   solr_doc['date_sort_dtsi']
#   # => '2019-12-01T00:00:00Z'
#
module IndexesSortableDate
  extend ActiveSupport::Concern

  included do
    class_attribute :sortable_date_property
    self.sortable_date_property = :date
  end

  # @return [Hash<String => *>]
  def generate_solr_document
    super.tap do |doc|
      doc['date_sort_dtsi'] = parse_sortable_date
    end
  end

  private

  # Converts whatever our +date_value+ is to a YYYY-MM-DDT00:00:00Z
  # string for Solr to use in sorting.
  #
  # @return [String]
  def parse_sortable_date
    raw = object.send(sortable_date_property).sort.first
    parsed = Date.edtf(raw)

    return Date.parse(object.create_date.to_s).strftime('%FT%TZ') if parsed.nil?

    # if we get an edtf range/set/etc, we want the earliest date.
    # rather than checking if it's a +EDTF::Set+, +EDTF::Interval+, etc.
    # we'll see if it's inherited from +Enumerable+ and call +#first+ if so
    parsed = parsed.first if parsed.class < ::Enumerable

    parsed.strftime('%FT%TZ')
  end
end
