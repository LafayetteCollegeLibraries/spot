# frozen_string_literal: true
RSpec.describe Spot::Mappers::RjwStereoMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper'

  describe '#date_associated' do
    subject { mapper.date_associated }

    let(:metadata) do
      { 'date.image.lower' => ['1921-01'], 'date.image.upper' => ['1932-02-11'] }
    end

    it { is_expected.to eq ['1921-01/1932-02-11'] }
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'creator.company' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'format.medium' }

    it_behaves_like 'a mapped field'
  end

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end
end
