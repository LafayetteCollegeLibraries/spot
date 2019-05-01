# frozen_string_literal: true
#
# Metadata mapper for the Shakespeare Bulletin Archive collection.
# See {Spot::Mappers::BaseMapper} for usage information.
module Spot::Mappers
  class ShakespeareBulletinMapper < BaseMapper
    include ShortDateConversion
    include NestedAttributes

    self.fields_map = {
      note: 'note',
      publisher: 'originInfo_Publisher',
      rights_statement: 'dc:rights',
      source: 'relatedItem_typeHost_titleInfo_title'
    }.freeze

    self.default_visibility = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    # @return [Array<Symbol>]
    def fields
      super + %i[
        creator
        date_issued
        editor
        identifier
        location_attributes
        resource_type
        subtitle
        title
      ]
    end

    # @todo Should we return URIs where possible?
    # @return [Array<String>]
    def creator
      names_with_role('author')
    end

    # Despite being labeled as 'ISO8601', Bulletin dates are in
    # mm/dd/yy format.
    #
    # @return [Array<String>]
    def date_issued
      Array(metadata['originInfo_dateIssued_ISO8601']).map do |raw|
        short_date_to_iso(raw, century_threshold: 50)
      end
    end

    # @todo Should we return URIs where possible?
    # @return [Array<String>]
    def editor
      names_with_role('editor')
    end

    # the Shakespeare Bulletin contains ISSNs as the sole identifier
    #
    # @return [Array<String>]
    def identifier
      Array(metadata['relatedItem_identifier_typeISSN']).reject(&:blank?).map do |value|
        "issn:#{value}"
      end
    end

    # Looking at the metadata, we should only have these three options for
    # locations, so we'll hard-code their geonames URIs.
    #
    # @return [Array<Hash>]
    def location_attributes
      nested_attributes_hash_for('originInfo_place_placeTerm') do |place|
        case place
        when 'Burlington, VT'
          'http://sws.geonames.org/5234372/'
        when 'Norwood, NJ'
          'http://sws.geonames.org/5101978/'
        when 'Easton, PA'
          'http://sws.geonames.org/5188140/'
        else
          Rails.logger.warn("No URI provided for #{place}; skipping")
          ''
        end
      end
    end

    # @return [Array<String>]
    def resource_type
      ['Periodical']
    end

    # @return [Array<RDF::Literal>]
    def subtitle
      (Array(metadata['titleInfo_subTitle']) + Array(metadata['titleInfo_partName']))
        .reject(&:blank?).map { |subtitle| RDF::Literal(subtitle, language: :en) }
    end

    # From our remediation notes:
    #
    #   Append <relatedItem_part1_date_qualifierApproximate>
    #     AND <relatedItem_part1_detaii1_typeVolume_caption>
    #     AND <relatedItem_part1_detail1_typeVolume_number
    #     AND <relatedItem_part1_detail1_typeIssue_caption>
    #     AND <relatedItem_part1_detail1_typeIssue_number>
    #     properties to title for Shakespeare Bulletin Collection.
    #
    # @return [Array<RDF::Literal>]
    def title
      base_title = metadata['titleInfo_Title']&.first
      date_qualifier = metadata['relatedItem_part1_date_qualifierApproximate']

      parenthetical = "(#{date_qualifier.first})" unless date_qualifier.blank?
      volume_issue = "[#{title_volume_issue}]" unless title_volume_issue.blank?

      joined = [base_title, parenthetical, volume_issue].reject(&:blank?).join(' ')

      [RDF::Literal(joined, language: :en)]
    end

    private

      # The metadata we're getting has four "name<number>_role" and
      # "name<number>_displayForm" properties for its authors/editors.
      # We'll iterate through to find those that match the requested role.
      #
      # @param [String] role
      # @return [Array<String>] MODS name fields for role
      def names_with_role(role)
        (1..4).to_a.reduce([]) do |results, num|
          role_key = "name#{num}_role"
          value_key = "name#{num}_displayForm"

          next results if metadata[role_key].blank? || metadata[value_key].blank?

          results += metadata["name#{num}_displayForm"] if metadata[role_key].first.include?(role)

          results
        end
      end

      # @return [String]
      def title_volume_issue
        volume_info = [
          metadata['relatedItem_part1_detail1_typeVolume_caption'],
          metadata['relatedItem_part1_detail1_typeVolume_number']
        ].flatten.join(' ').strip

        issue_info = [
          metadata['relatedItem_part1_detail1_typeIssue_caption'],
          metadata['relatedItem_part1_detail1_typeIssue_number']
        ].flatten.join(' ').strip

        [volume_info, issue_info].reject(&:blank?).join(', ').strip
      end
  end
end
