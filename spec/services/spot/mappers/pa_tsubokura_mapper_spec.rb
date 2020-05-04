# frozen_string_literal: true
RSpec.describe Spot::Mappers::PaTsubokuraMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper'

  # fields_map testing
  [
    [:creator, 'creator.maker'],
    [:date_scope_note, 'description.indicia'],
    [:keyword, 'relation.ispartof'],
    [:language],
    [:physical_medium, 'format.medium'],
    [:publisher, 'creator.company'],
    [:resource_type, 'resource.type'],
    [:subject_ocm, 'subject.ocm']
  ].each do |(method, key)|
    describe "##{method}" do
      subject { mapper.send(method) }

      let(:field) { key || method.to_s }

      it_behaves_like 'a mapped field'
    end
  end

  describe '#inscription' do
    subject { mapper.inscription }

    context 'description.inscription.japanese' do
      let(:value) { 'postmark: 38-11-23' }
      let(:metadata) { { 'description.inscription.japanese' => [value] } }

      it { is_expected.to eq [RDF::Literal(value, language: nil)] }
    end

    context 'description.text.japanese' do
      let(:value) { '台湾総督府始政十年記念' }
      let(:metadata) { { 'description.text.japanese' => [value] } }

      it { is_expected.to eq [RDF::Literal(value, language: :ja)] }
    end
  end

  describe '#related_resource' do
    subject { mapper.related_resource }

    let(:metadata) do
      { 'description.citation' => ['[ww0001]'], 'relation.seealso' => ['another resource'] }
    end

    it { is_expected.to eq ['[ww0001]', 'another resource'] }
  end
end
