# frozen_string_literal: true
RSpec.describe AudioVisualResourceIndexer, valkyrization: true do
  let(:solr_document) { described_class.new(resource: resource).to_solr }
  let(:resource) { FactoryBot.valkyrie_create(:audio_visual_resource_with_required_fields_only) }

  it_behaves_like 'a BaseResourceIndexer'

  describe 'audio_visual_metadata' do
    it_behaves_like 'it indexes', :date, to: ['date_ssim']
    it_behaves_like 'it indexes', :date_associated, to: ['date_associated_ssim']
    it_behaves_like 'it indexes', :inscription, to: ['inscription_tesim']
    it_behaves_like 'it indexes', :original_item_extent, to: ['original_item_extent_tesim']
    it_behaves_like 'it indexes', :repository_location, to: ['repository_location_ssim']
    it_behaves_like 'it indexes', :research_assistance, to: ['research_assistance_ssim']
    it_behaves_like 'it indexes', :provenance, to: ['provenance_tesim']
    it_behaves_like 'it indexes', :barcode, to: ['barcode_ssim']
  end
end
