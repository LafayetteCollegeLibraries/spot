# frozen_string_literal: true
RSpec.describe Spot::Derivatives::AvValkyrieDerivativeService, derivatives: true do
  context "when given an audio file" do
    let(:valid_file_metadata) do
      FactoryBot.valkyrie_create(:hyrax_file_metadata, :audio_file, file_set_id: SecureRandom.uuid)
    end

    let(:file_metadata) { valid_file_metadata }
    let(:service) { described_class.new(file_metadata) }
    let(:_file_set) { build(:file_set, id: 'abcd1234') }
    let(:file_set) { _file_set }
    let(:src_path) { '/original/path/to/src/file.mp3' }

    it_behaves_like "a Spot::DerivativeService"

    before do 
      allow(file_metadata).to receive(:file_set_id).and_return('abcd1234')
      allow(Hyrax.query_service).to receive(:find_by).with(id: 'abcd1234').and_return(file_set)
    end

    describe "#create_derivatives" do
      subject { service.create_derivatives(filename) }

      let(:filename) { src_path }

      before do
        service.create_derivatives(filename)
      end

      it 'creates derivative files' do
        expect(Hydra::Derivatives::AudioDerivatives).to have_received(:create).with(filename)
      end
    end
  end

  context "when given an video file" do
    let(:valid_file_metadata) do
      FactoryBot.valkyrie_create(:hyrax_file_metadata, :video_file, file_set_id: SecureRandom.uuid)
    end

    let(:file_metadata) { valid_file_metadata }
    let(:service) { described_class.new(file_metadata) }
    let(:_file_set) { build(:file_set, id: 'abcd1234') }
    let(:file_set) { _file_set }
    let(:src_path) { '/original/path/to/src/file.mp4' }

    it_behaves_like "a Spot::DerivativeService"

    before do 
      allow(file_metadata).to receive(:file_set_id).and_return('abcd1234')
      allow(Hyrax.query_service).to receive(:find_by).with(id: 'abcd1234').and_return(file_set)
    end

    describe "#create_derivatives" do
      subject { service.create_derivatives(filename) }

      let(:filename) { src_path }
      let(:mock_ffprobe) { instance_double(Ffprober::Wrapper, video_streams: [stream]) }
      let(:stream) { double(width: 100, height: 200) }

      before do
        service.create_derivatives(filename)
        allow(Ffprober::Parser).to receive(:from_file).with(filename).and_return(mock_ffprobe)
      end

      it 'creates derivative files' do
        expect(Hydra::Derivatives::VideoDerivatives).to have_received(:create).with(filename)
      end
    end
  end
end
