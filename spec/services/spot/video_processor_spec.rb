# frozen_string_literal: true
describe Spot::VideoProcessor do
  subject { described_class.new(file_name, directives) }

  let(:file_name) { 'foo/bar.mov' }

  describe ".config" do
    before do
      @original_config = described_class.config.dup
      described_class.config.mpeg4.codec = "-vcodec mpeg4 -acodec aac -strict -2"
    end

    after { described_class.config = @original_config }
    let(:directives) { { label: :thumb, format: "mp4", url: 'http://localhost:8983/fedora/rest/dev/1234/thumbnail' } }

    it "is configurable" do
      expect(subject).to receive(:encode_file).with("mp4", Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => "-s 320x240 -vcodec mpeg4 -acodec aac -strict -2 -g 30 -b:v 345k -ac 2 -ab 96k -ar 44100", Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => "")
      subject.process
    end
  end

  context "when arguments are passed as a hash" do
    context "when a video format is requested" do
      let(:directives) { { label: :thumb, format: 'webm', url: 'http://localhost:8983/fedora/rest/dev/1234/thumbnail' } }

      it "creates a fedora resource and infers the name" do
        expect(subject).to receive(:encode_file).with("webm", Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => "-s 320x240 -vcodec libvpx -acodec libvorbis -g 30 -b:v 345k -ac 2 -ab 96k -ar 44100", Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => "")
        subject.process
      end
    end

    context "when a jpg is requested" do
      let(:directives) { { label: :thumb, format: 'jpg', url: 'http://localhost:8983/fedora/rest/dev/1234/thumbnail' } }

      it "creates a fedora resource and infers the name" do
        expect(subject).to receive(:encode_file).with("jpg", output_options: "-s 320x240 -vcodec mjpeg -vframes 1 -an -f rawvideo", input_options: " -itsoffset -2")
        subject.process
      end
    end

    context "when an mkv is requested" do
      let(:directives) { { label: :thumb, format: 'mkv', url: 'http://localhost:8983/fedora/rest/dev/1234/thumbnail' } }

      it "creates a fedora resource and infers the name" do
        expect(subject).to receive(:encode_file).with("mkv", Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => "-s 320x240 -vcodec ffv1 -g 30 -b:v 345k -ac 2 -ab 96k -ar 44100", Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => "")
        subject.process
      end
    end

    context "when an unknown format is requested" do
      let(:directives) { { label: :thumb, format: 'nocnv', url: 'http://localhost:8983/fedora/rest/dev/1234/thumbnail' } }

      it "raises an ArgumentError" do
        expect { subject.process }.to raise_error ArgumentError, "Unknown format `nocnv'"
      end
    end
  end
end