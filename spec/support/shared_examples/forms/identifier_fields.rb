# frozen_string_literal: true
RSpec.shared_examples 'it handles identifier form fields' do
  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }

    it { is_expected.to include(standard_identifier_prefix: [], standard_identifier_value: []) } if
      described_class.terms.include?(:standard_identifier)

    it { is_expected.to include(local_identifier: []) } if
      described_class.terms.include?(:local_identifier)
  end

  describe '.model_attributes' do
    subject(:attributes) { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(raw_params) }

    if described_class.terms.include?(:standard_identifier)
      context 'when the params include standard_identifier values' do
        let(:raw_params) do
          {
            standard_identifier_prefix: ['hdl'],
            standard_identifier_value: ['10385/abc123def']
          }
        end

        it 'parses + inserts the values into :identifier' do
          expect(attributes[:identifier]).to include 'hdl:10385/abc123def'
        end
      end
    end

    if described_class.terms.include?(:local_identifier)
      context 'when the params include local_identifier values' do
        let(:raw_params) do
          { local_identifier: ['noid:abcdef123', 'local:some-identifier'] }
        end

        it 'parses + combines standard + local identifiers' do
          expect(attributes[:identifier]).to include('noid:abcdef123', 'local:some-identifier')
        end
      end
    end
  end

  describe 'identifier accessors' do
    let(:work_klass) { described_class.name.split('::').last.gsub(/Form$/, '').constantize }
    let(:work) { work_klass.new(identifier: identifiers) }
    let(:form) { described_class.new(work, nil, nil) }

    let(:identifiers) do
      [
        'issn:1234-5678', # standard
        'local:abc123' # local
      ]
    end

    describe '#standard_identifier' do
      subject { form.standard_identifier }

      it { is_expected.to eq ['issn:1234-5678'] }
    end

    describe '#local_identifier' do
      subject { form.local_identifier }

      it { is_expected.to eq ['local:abc123'] }

      context 'when a noid exists' do
        let(:identifiers) { ['local:abc123', 'noid:abc123def'] }

        it { is_expected.not_to include 'noid:abc123def' }
      end
    end

    describe '.multiple?' do
      subject { form.multiple?(field) }

      context 'local_identifier' do
        let(:field) { :local_identifier }

        it { is_expected.to be true }
      end

      context 'standard_identifier' do
        let(:field) { :standard_identifier }

        it { is_expected.to be true }
      end
    end
  end
end
