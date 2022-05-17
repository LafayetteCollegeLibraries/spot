# frozen_string_literal: true
RSpec.describe Spot::Importers::CSV::Parser, feature: :csv_ingest_service do
  let(:csv_file) { StringIO.new(csv_string) }
  let(:csv_string) do
    "title,creator,file\n" \
    "My First Publication,\"Author, Anne\",publication_1.pdf\n" \
    "My Honors Thesis,\"Author-Name, Anne-Other\",student_work_1.docx\n"
  end
  let(:parser) { described_class.new(file: csv_file, work_type: work_type) }
  let(:work_type) { :publication }

  it 'passes the work_type to the Mapper' do
    expect(parser.records.all? { |record| record.mapper.work_type == Publication }).to be true
  end

  describe '.match?' do
    xit 'matches CSV files'
  end

  describe '#records' do
    it 'yields an InputRecord for each row' do
      expect { |block| parser.records(&block) }
        .to yield_successive_args(Darlingtonia::InputRecord, Darlingtonia::InputRecord)
    end

    context 'when work_type is provided in the metadata' do
      let(:csv_string) do
        "work_type,title,creator,file\n" \
        "Publication,My First Publication,\"Author, Anne\",publication_1.pdf\n" \
        "image,A Photograph,Anonymous,image_1.tif\n" \
        "student_work,My Honors Thesis,\"Author-Name, Anne-Other\",student_work_1.docx\n"
      end

      it 'uses the work_types provided in the CSV file' do
        expect(parser.records.map { |record| record.mapper.work_type }).to eq [Publication, Image, StudentWork]
      end
    end

    context 'when no work_type is provided' do
      let(:work_type) { nil }
      it 'raises an exception' do
        expect { parser.records }.to raise_error(RuntimeError, 'No work_type provided to Parser')
      end
    end
  end
end
