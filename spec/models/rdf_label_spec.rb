# frozen_string_literal: true
RSpec.describe RdfLabel do
  before do
    described_class.destroy_all
  end

  # r
  describe '.destroy_by' do
    before do
      described_class.create!([
        { uri: 'https://ldr.lafayette.edu', value: 'Lafayette Digital Repository' },
        { uri: 'https://tumblr.com', value: 'Tumblr' }
      ])
    end

    it 'destroys labels using .find_by params' do
      expect { described_class.destroy_by(uri: 'https://tumblr.com') }
        .to change { described_class.count }
        .from(2)
        .to(1)
    end
  end

  describe '.label_for' do
    before do
      described_class.create!(uri: 'https://ldr.lafayette.edu', value: 'Lafayette Digital Repository')
    end

    it 'returns the label value' do
      expect(described_class.label_for(uri: 'https://ldr.lafayette.edu')).to eq 'Lafayette Digital Repository'
    end
  end
end
