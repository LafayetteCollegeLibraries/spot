# frozen_string_literal: true
RSpec.describe Spot::ImageServerFileResolver do
  describe '#pattern' do
    subject { service.pattern(id) }

    let(:service) { described_class.new }
    let(:id) { 'abc123def' }
    let(:path) do
      Rails.root.join('tmp', 'derivatives', 'ab', 'c1', '23', 'de', 'f-access.{png,jpg,tif,tiff,jp2}').to_s
    end

    it { is_expected.to eq path }
  end
end
