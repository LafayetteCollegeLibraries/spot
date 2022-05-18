# frozen_string_literal: true
RSpec.describe Spot::Validators::WorkTypeValidator, feature: :csv_ingest_service do
  subject(:errors) { validator.validate(parser: parser) }

  let(:validator) { described_class.new }
  let(:parser) { Spot::Importers::CSV::Parser.new(file: file) }
  let(:file) { StringIO.new(csv_content) }

  let(:csv_content) do
    "work_type,title,creator\n" \
    "#{valid_work_type},A Valid Document,\"Author, Anne\"\n" \
    "#{invalid_work_type},Another Document,\"Authorname, Anne-Other\"\n"
  end

  let(:valid_work_type) { 'publication' }
  let(:invalid_work_type) { 'nope' }

  context 'when CSV contains invalid work_types' do
    it 'returns an array of Errors' do
      expect(errors.all? { |err| err.is_a?(Darlingtonia::Validator::Error) }).to be true
    end

    it 'contains details' do
      error = errors.first
      expect(error.name).to eq 'Invalid work_type'
      expect(error.lineno).to eq 3
    end
  end

  context 'when CSV contains valid work_types' do
    let(:invalid_work_type) { valid_work_type }

    it { is_expected.to be_empty }
  end
end
