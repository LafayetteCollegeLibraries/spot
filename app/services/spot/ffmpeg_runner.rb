# frozen_string_literal: true
module Spot
  class FfmpegRunner
    class_attribute :config
    self.config = Hydra::Derivatives::Processors::Video::Config.new

    def create (file, output_file, options)
      if options[:format] == "mp3"
          encode_file(file, nil, output_file)
      end

      output_options = parse_output(options)

      encode(file, output_options, output_file)
    end

    def parse_output (options)
      output_options = "-s #{size_attributes(options)} #{codecs(options[:format])}"
      output_options += " #{video_attributes(options)} #{audio_attributes(options)}"
      output_options
    end

    def size_attributes (options)
      options[:size].nil? ? Hydra::Derivatives.config.size_attributes : options[:size]
    end

    def video_attributes (options)
      attrs = options[:video] if options[:video].present?
      # If you have set Hydra::Derivatives::Processors::Video::Processor.config.video_attributes and want to customize the bitrate
      # in the directives then you will need to pass the video parameter in the directives instead.
      attrs ||= config.default_video_attributes(options[:bitrate]) if options[:bitrate].present?
      attrs ||= config.video_attributes
      attrs
    end

    def audio_attributes (options)
      options[:audio].nil? ? config.audio_attributes : options[:audio]
    end

    def codecs(format)
          case format
          when 'mp4'
            config.mpeg4.codec
          when 'webm'
            config.webm.codec
          when "mkv"
            config.mkv.codec
          when "jpg"
            config.jpeg.codec
          else
            raise ArgumentError, "Unknown format `#{format}'"
          end
        end

    def encode_file(path, output_options, output_file)
      inopts = "-y"
      outopts = output_options ||= ""
      Hydra::Derivatives::Processors::Video::Processor.execute "#{Hydra::Derivatives.ffmpeg_path} #{inopts} -i #{path} #{outopts} #{output_file}"
    end
  end
end