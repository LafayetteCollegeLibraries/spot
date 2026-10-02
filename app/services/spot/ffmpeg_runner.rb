# frozen_string_literal: true
module Spot
  class FfmpegRunner
    def create (file, output_file, options)
      if options[:format] == "mp3"
        encode_file(file, nil, output_file)
        return
      end

      output_options = parse_output(options)

      encode_file(file, output_options, output_file)
    end

    def parse_output (options)
      output_options = "-s #{size_attributes(options)} #{codecs(options[:format])}"
      output_options += " #{video_attributes(options)} #{audio_attributes(options)}"
      output_options
    end

    def size_attributes (options)
      options[:size].nil? ? "320x240" : options[:size]
    end

    def video_attributes (options)
      attrs = options[:video] if options[:video].present?
      # If you have set Hydra::Derivatives::Processors::Video::Processor.config.video_attributes and want to customize the bitrate
      # in the directives then you will need to pass the video parameter in the directives instead.
      attrs ||= "-g 30 -b:v #{options[:bitrate]}" if options[:bitrate].present?
      attrs ||= "-g 30 -b:v 345k"
      attrs
    end

    def audio_attributes (options)
      options[:audio].nil? ? "-ac 2 -ab 96k -ar 44100" : options[:audio]
    end

    def codecs(format)
      case format
      when 'mp4'
        "-vcodec libx264 -profile:v high -pix_fmt yuv420p -acodec aac"
      when 'webm'
        '-vcodec libvpx -acodec libvorbis'
      when "mkv"
        '-vcodec ffv1'
      when "jpg"
        '-vcodec mjpeg'
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