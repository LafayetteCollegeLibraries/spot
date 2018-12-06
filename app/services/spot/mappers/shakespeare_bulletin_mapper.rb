module Spot::Mappers
  class ShakespeareBulletinMapper < BaseMapper
    include ShortDateConversion
    include NestedAttributes

    self.fields_map = {
      publisher: 'originInfo_Publisher',
      source: 'relatedItem_typeHost_titleInfo_title',
    }.freeze

    def fields
      super + %i[
        based_near_attributes
        creator
        date_issued
        editor
        identifier
        subtitle
        title
      ]
    end

    # @return [Array<Hash>]
    def based_near_attributes
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
      metadata['originInfo_dateIssued_ISO8601'].map do |raw|
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
      metadata['relatedItem_identifier_typeISSN'].reject(&:blank?).map do |value|
        "issn:#{value}"
      end
    end

    # @return [Array<RDF::Literal>]
    def subtitle
      metadata['titleInfo_subTitle'].reject(&:blank?).map do |subtitle|
        RDF::Literal(subtitle, language: :en)
      end
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
      base_title = metadata['titleInfo_Title'].first
      date_qualifier = metadata['relatedItem_part1_date_qualifierApproximate']
      volume_info = [
        metadata['relatedItem_part1_detail1_typeVolume_caption'],
        metadata['relatedItem_part1_detail1_typeVolume_number']
      ].flatten.join(' ').strip
      issue_info = [
        metadata['relatedItem_part1_detail1_typeIssue_caption'],
        metadata['relatedItem_part1_detail1_typeIssue_number']
      ].flatten.join(' ').strip

      volume_issue_block = [volume_info, issue_info]
                             .reject(&:blank?)
                             .join(', ')
                             .strip

      parenthetical = "(#{date_qualifier.first})" unless date_qualifier.blank?
      volume_issue = "[#{volume_issue_block}]" unless volume_issue_block.blank?

      joined = [base_title, parenthetical, volume_issue].reject(&:blank?).join(' ')

      [RDF::Literal(joined, language: :en)]
    end

    private

    # @param [String] role
    # @return [Array<String>] MODS name fields for role
    def names_with_role(role)
      (1..4).to_a.reduce([]) do |results, num|
        role_key = "name#{num}_role"
        value_key = "name#{num}_displayForm"

        next if metadata[role_key].blank?

        if metadata[role_key].first.include?(role) && metadata[value_key].present?
          results += metadata[value_key]
        end

        results
      end
    end
  end
end
