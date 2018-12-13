# frozen_string_literal: true
require 'tmpdir'

RSpec.describe Spot::Validators::BagValidator do
  let(:validator) { described_class.new(error_stream: error_stream) }

  let(:error_stream) { File.open(File::NULL, 'w') }
  let(:parser) { instance_double('Spot::Importers::Bag::Parser') }
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:bag) { fixtures_path.join('sample-bag') }

  before do
    allow(parser).to receive(:file).and_return(bag)
  end

  describe '#validate' do
    subject { validator.validate(parser: parser) }

    context 'when bag does not exist' do
      let(:bag) { '/does/not/exist' }

      it { is_expected.not_to be_empty }
      it { is_expected.to include 'Bag does not exist' }
    end

    context 'when bag is not a directory' do
      let(:bag) { fixtures_path.join('zip-test-fixture.zip') }

      it { is_expected.not_to be_empty }
      it { is_expected.to include 'Bag is not a directory' }
    end

    context 'when bag is invalid' do
      # s/o to https://stackoverflow.com/a/17512070
      Dir.mktmpdir do |dir|
        let(:bag) { dir }

        it { is_expected.not_to be_empty }
        it { is_expected.not_to include 'is invalid' }
      end
    end

    context 'when bag is valid' do
      it { is_expected.to be_empty }
    end
  end
end
