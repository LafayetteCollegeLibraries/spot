# frozen_string_literal: true
RSpec.describe Spot::WorkAndFileSetSearchBuilder do
  let(:builder) { described_class.new([]) }

  describe '#filter_models' do
    subject(:params) { {} }

    before { builder.filter_models(params) }

    it 'adds a :fq key' do
      expect(params).to include :fq
    end

    it 'is an array' do
      expect(params[:fq]).to be_an Array
    end

    it 'adds FileSet to the list of models to search' do
      expect(params[:fq].first).to start_with '{!terms f=has_model_ssim}'
      expect(params[:fq].first).to include 'FileSet'
    end
  end
end
