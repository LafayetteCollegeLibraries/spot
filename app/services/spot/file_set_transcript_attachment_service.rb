# frozen_string_literal: true
module Spot
  # Convenience service to attach a transcript file to a file_set
  #
  # @usage
  #   Spot::FileSetTranscriptAttachmentService.attach(path: '/path/to/subtitle.vtt', file_set: file_set)
  #
  class FileSetTranscriptAttachmentService
    # @param [Hash] options
    # @option [String] path
    # @option [FileSet] file_set
    # @option [User, nil] depositor (defaults to the file_set's depositing user)
    def self.attach(path:, file_set:, depositor: nil)
      new(file_set: file_set, depositor: depositor).attach_transcript(path: path)
    end

    def initialize(file_set:, depositor: nil)
      @file_set = file_set
      @depositor = depositor.presence || file_set_depositor
    end

    def attach_transcript(path:)
      job_io = wrap_transcript_io(path)
      Hyrax::Actors::FileSetActor.new(@file_set, @depositor).create_content(job_io, :transcript)
    end

    private

    # should this be the bot user instead?
    def file_set_depositor
      User.find_by(email: @file_set.depositor)
    end

    def wrap_transcript_io(path)
      JobIoWrapper.create_with_varied_file_handling!(user: @depositor,
                                                     file: File.open(path, 'r'),
                                                     relation: :transcript,
                                                     file_set: @file_set)
    end
  end
end
