# frozen_string_literal: true
RSpec.describe Spot::Derivatives::BaseDerivativesService do
  subject(:service) { described_class.new(file_set) }

  let(:file_set) { FileSet.new }

  describe '#cleanup_derivatives' do
    it 'is not implemented' do
      expect { service.cleanup_derivatives }.to raise_error(NotImplementedError)
    end
  end

  describe '#create_derivatives' do
    it 'is not implemented' do
      expect { service.create_derivatives('filename') }.to raise_error(NotImplementedError)
    end
  end
end
