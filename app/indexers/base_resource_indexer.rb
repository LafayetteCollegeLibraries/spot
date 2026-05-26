# frozen_string_literal: true
#
# Indexer for properties common among our work types.
#
# @example
#   class NewResourceIndexer < BaseResourceIndexer
#     #...
#   end
#
class BaseResourceIndexer < Hyrax::Indexers::PcdmObjectIndexer
  include Hyrax::Indexer(:core_metadata)
  include Hyrax::Indexer(:base_metadata)

  class_attribute :sortable_date_field, default: :date
  class_attribute :years_encompassed_fields, default: [:date]

  # @todo update the HandleService to generate this and then call from here
  # include IndexesPermalink

  def to_solr
    super.tap do |doc|
      doc.merge!(
        citation_metadata,
        language_and_label,
        rights_statement_and_labels,
        {
          'date_sort_dtsi' => parse_sortable_date,
          'years_encompassed_iim' => parse_years_encompassed
        }
      )

      # Ensure that the solr_document doesn't contain any RDF::Literals,
      # as they convert to JSON-LD and Solr throws a fit about JSON-LD keys.
      doc.each_pair do |key, val|
        if val.is_a?(Array)
          doc[key] = val.map { |v| v.is_a?(RDF::Literal) ? v.value : v }
        end
      end
    end
  end

  private

  def citation_metadata
    return {} unless resource.respond_to?(:bibliographic_citation) && resource.bibliographic_citation.present?

    raw = Array.wrap(resource.bibliographic_citation).first
    parsed = ::AnyStyle.parse(raw)&.first
    return {} if parsed.blank? || parsed[:type].nil?

    first_page, last_page = parsed[:pages]&.first&.split(/[-–—]/, 2)

    {
      'citation_journal_title_ss' => parsed[:'container-title']&.first,
      'citation_volume_ss' => parsed[:volume]&.first,
      'citation_issue_ss' => parsed[:issue]&.first,
      'citation_firstpage_ss' => first_page,
      'citation_lastpage_ss' => last_page

    }
  end

  def language_and_label
    return {} if resource.language.empty?

    {
      'language_ssim' => resource.language.map(&:to_s),
      'language_label_ssim' => resource.language.map { |lang| Spot::ISO6391.label_for(lang) }
    }
  end

  # Uses either the earliest date in metadata (using .sortable_date_field attribute)
  # or falls back to the create_date of the resource to determine a date to use for sorting.
  def parse_sortable_date
    value = (resource.try(sortable_date_field) || []).sort.first
    return if value.blank?

    parsed = Date.edtf(value)
    parsed = parsed.first if parsed.class < ::Enumerable # guard for EDTF sets/intervals/etc
    parsed ||= Date.parse(resource.create_date.to_s)

    parsed.strftime('%FT%TZ')
  end

  # "Years Encompassed" meaning what years are covered by the metadata dates for a resource.
  # Handles individual dates and EDTF ranges (so "2001/2003" encompasses "2001", "2002", "2003").
  # Used for the blacklight_range_limit plugin.
  def parse_years_encompassed
    fields = Array.wrap(years_encompassed_fields)
    return [] unless fields.any? { |field| resource.respond_to?(field) }

    fields.map { |f| resource.try(f).try(:to_a) || [] }
          .flatten
          .reduce([]) { |dates, date|
            parsed = Date.edtf(date)
            next (dates + [parsed.year]) if parsed.is_a? Date
            next dates if parsed.nil? || !parsed.respond_to?(:map)

            dates + parsed.map(&:year)
          }
          .sort
          .uniq
  end

  def rights_statement_and_labels
    {
      'rights_statement_ssim' => rights_statement_uris,
      'rights_statement_label_ssim' => rights_statement_uris.map { |uri| rights_statement_service.label(uri) { uri } },
      'rights_statement_shortcode_ssim' => rights_statement_uris.map { |uri| rights_statement_service.shortcode(uri) { nil } }
    }
  end

  def rights_statement_service
    @rights_statement_service ||= Hyrax.config.rights_statement_service_class.new
  end

  def rights_statement_uris
    @rights_statement_uris ||= resource.rights_statement.map(&:to_s)
  end
end
