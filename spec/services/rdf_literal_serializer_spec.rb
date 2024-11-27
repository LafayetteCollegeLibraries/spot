# frozen_string_literal: true
RSpec.describe RdfLiteralSerializer do
  describe '#deserialize' do
    subject { described_class.deserialize(value) }

    let(:value) { '"Cool Beans"' }

    it { is_expected.to eq RDF::Literal('Cool Beans') }

    context 'when it has a language' do
      let(:value) { '"Cool Beans"@en' }

      it { is_expected.to eq RDF::Literal('Cool Beans', language: :en) }
    end
  end

  describe '#serialize' do
    subject { described_class.serialize(value) }

    context 'when it is an RDF::Literal' do
      let(:value) { RDF::Literal('Cool Beans', language: :en) }

      it { is_expected.to eq '"Cool Beans"@en' }
    end

    context 'when it is not an RDF::Literal' do
      let(:value) { 'Uh oh' }

      it { is_expected.to eq '"Uh oh"' }
    end
  end
end
