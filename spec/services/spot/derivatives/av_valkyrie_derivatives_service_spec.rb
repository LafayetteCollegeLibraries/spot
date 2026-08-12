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
        allow(Hydra::Derivatives::AudioDerivatives).to receive(:create)
        service.create_derivatives(filename)
      end

      it 'creates derivative files' do
        expect(Hydra::Derivatives::AudioDerivatives).to have_received(:create).with(
          filename,
          outputs: contain_exactly(
            hash_including(label: 'mp3', format: 'mp3', url: 'file:///spot/tmp/derivatives/ab/cd/12/34-mp3.mp3')
          )
        )
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
        allow(Ffprober::Parser).to receive(:from_file).with(filename).and_return(mock_ffprobe)
        allow(Hydra::Derivatives::VideoDerivatives).to receive(:create)
        service.create_derivatives(filename)
      end

      it 'creates derivative files' do
        expect(Hydra::Derivatives::VideoDerivatives).to have_received(:create).with(
          filename,
          outputs: contain_exactly(
            hash_including(
                            label: 'webm',
                            format: 'webm',
                            url: 'file:///spot/tmp/derivatives/ab/cd/12/34-webm.webm',
                            size: '240x480',
                            mime_type: 'video/webm',
                            input_options: "-ss 1",
                            video: "-g 30 -b:v 2500k",
                            audio: "-b:a 256k -ar 44100"
                          ),
            hash_including(
                            label: 'mp4',
                            format: 'mp4',
                            url: 'file:///spot/tmp/derivatives/ab/cd/12/34-mp4.mp4',
                            size: '544x1080',
                            mime_type: 'video/mp4',
                            input_options: "-ss 1",
                            video: "-g 30 -b:v 8000k",
                            audio: "-b:a 256k -ar 44100"
                          )
          )
        )
      end
    end
  end
end
