# frozen_string_literal: true
RSpec.describe FileSet do
  it_behaves_like 'a model with hyrax core metadata'
  it_behaves_like 'it accepts "metadata" as a visibility'

  describe "#file_set_derivatives_service" do
    subject(:file_set) { described_class.new }

    before do
      allow(Hyrax::DerivativeService).to receive(:for).with(file_set)
    end

    it 'fetches derivative services for itself' do
      file_set.send(:file_set_derivatives_service)
      expect(Hyrax::DerivativeService).to have_received(:for).with(file_set)
    end
  end
end
