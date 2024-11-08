# frozen_string_literal: true
RSpec.describe StudentWorkResourceIndexer, valkyrization: true do
  it_behaves_like 'a BaseResourceIndexer'

  describe 'student_work_metadata' do
    it_behaves_like 'it indexes', :abstract, to: ['abstract_tesim']
    it_behaves_like 'it indexes', :access_note, to: ['access_note_tesim']
    it_behaves_like 'it indexes', :advisor, to: ['advisor_ssim']
    it_behaves_like 'it indexes', :date, to: ['date_ssim']
    it_behaves_like 'it indexes', :date_available, to: ['date_available_ssim']
  end
end
