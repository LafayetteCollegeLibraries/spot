# frozen_string_literal: true
module Spot
  class VideoProcessor < ::Hydra::Derivatives::Processors::Video::Processor
    include ::Hydra::Derivatives::Processors::Ffmpeg

    def options_for(format)
      input_options = ""
      output_options = "-s #{size_attributes} #{codecs(format)}"
      if format == "jpg"
        input_options += " -itsoffset -2"
        output_options += " -vframes 1 -an -f rawvideo"
      else
        input_options += @directives[:input_options] if @directives[:input_options].present?
        output_options += " #{video_attributes} #{audio_attributes}"
      end

      { ::Hydra::Derivatives::Processors::Ffmpeg::OUTPUT_OPTIONS => output_options, ::Hydra::Derivatives::Processors::Ffmpeg::INPUT_OPTIONS => input_options }
    end

    def size_attributes
      @directives[:size].nil? ? config.size_attributes : @directives[:size]
    end

    def video_attributes
      attrs = @directives[:video] if @directives[:video].present?
      # If you have set Hydra::Derivatives::Processors::Video::Processor.config.video_attributes and want to customize the bitrate
      # in the directives then you will need to pass the video parameter in the directives instead.
      attrs ||= config.default_video_attributes(@directives[:bitrate]) if @directives[:bitrate].present?
      attrs ||= config.video_attributes
      attrs
    end

    def audio_attributes
      @directives[:audio].nil? ? config.audio_attributes : @directives[:audio]
    end
  end
end
