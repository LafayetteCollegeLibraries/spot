# frozen_string_literal: true
class StudentWorkIndexer < BaseIndexer
  self.sortable_date_property = :date

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['advisor_ssim'] = object.advisor.to_a
      solr_doc['advisor_label_ssim'] = object.advisor.map { |lnumber| advisor_label_from(lnumber: lnumber) }
    end
  end

  private

  def advisor_label_from(lnumber:)
    return lnumber unless lnumber.match?(/^L\d{8}$/)

    Spot::LafayetteInstructorsAuthorityService.label_for(lnumber: lnumber)
  end
end
