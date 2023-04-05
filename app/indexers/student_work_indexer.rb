# frozen_string_literal: true
class StudentWorkIndexer < BaseIndexer
  self.sortable_date_property = :date

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['advisor_ssim'] = object.advisor.to_a
      solr_doc['advisor_label_ssim'] = object.advisor.map { |email| advisor_label_from(email: email) }
    end
  end

  private

  def advisor_label_from(email:)
    return email unless email.end_with?('@lafayette.edu')

    Spot::LafayetteInstructorsAuthorityService.label_for(email: email)
  end
end
