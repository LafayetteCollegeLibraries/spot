# frozen_string_literal: true
RSpec.describe ImageResourceIndexer, valkyrization: true do
  let(:solr_document) { described_class.new(resource: resource).to_solr }
  let(:resource) { FactoryBot.valkyrie_create(:image_resource_with_required_fields_only) }

  it_behaves_like 'a BaseResourceIndexer'

  describe 'image_metadata' do
    it_behaves_like 'it indexes', :date, to: ['date_ssim']
    it_behaves_like 'it indexes', :date_associated, to: ['date_associated_ssim']
    it_behaves_like 'it indexes', :date_scope_note, to: ['date_scope_note_tesim']
    it_behaves_like 'it indexes', :donor, to: ['donor_ssim']
    it_behaves_like 'it indexes', :inscription, to: ['inscription_tesim']
    it_behaves_like 'it indexes', :original_item_extent, to: ['original_item_extent_tesim']
    it_behaves_like 'it indexes', :repository_location, to: ['repository_location_ssim']
    it_behaves_like 'it indexes', :requested_by, to: ['requested_by_ssim']
    it_behaves_like 'it indexes', :research_assistance, to: ['research_assistance_ssim']
    it_behaves_like 'it indexes', :subject_ocm, to: ['subject_ocm_ssim', 'subject_ocm_tesim']
  end
end
