module Spot::Mappers
  class ShakespeareBulletinMapper < HashMapper
    include ShortDateConversion

    self.fields_map = {
      publisher: 'originInfo_Publisher',
      source: 'relatedItem_typeHost_titleInfo_title',
      subtitle: 'titleInfo_subTitle'
    }.freeze

    def fields
      super + %i[
        creator
        date_issued
        editor
        identifier
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

    # From our remediation notes:
    #
    #   Append <relatedItem_part1_date_qualifierApproximate>
    #     AND <relatedItem_part1_detaii1_typeVolume_caption>
    #     AND <relatedItem_part1_detail1_typeVolume_number
    #     AND <relatedItem_part1_detail1_typeIssue_caption>
    #     AND <relatedItem_part1_detail1_typeIssue_number>
    #     properties to title for Shakespeare Bulletin Collection.
    #
    # @return [Array<String>]
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

      [[base_title, parenthetical, volume_issue].reject(&:blank?).join(' ')]
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
