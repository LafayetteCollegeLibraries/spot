# frozen_string_literal: true
class StudentWorkResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:student_work_metadata)
  include Hyrax::Indexer(:institutional_metadata)

  self.sortable_date_field = :date
  self.years_encompassed_fields = [:date]

  def to_solr
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
