# frozen_string_literal: true

# A thin-wrapper around a logger to allow the shovel operator.
#
# Darlingtonia::RecordImporter has kwargs to provide an `info_stream`
# and `error_stream` for logging. This is expected to be a writable
# stream, rather than a logger object. Spot::StreamLogger allows us
# to provide an object to these arguments but have the output be
# the same as the rest of our logs.
#
# @example
#   info_stream = Spot::StreamLogger.new(Rails.logger, ::Logger::INFO)
#   error_stream = Spot::StreamLogger.new(Rails.logger, ::Logger::WARN)
#   importer = Darlingtonia::RecordImporter.new(info_stream: info_stream,
#                                               error_stream: error_stream)
#
module Spot
  class StreamLogger
    # @param logger [Logger] instance of logger to use
    # @param level [Integer] logger level that shovel operator writes to
    def initialize(logger, level: ::Logger::INFO)
      @logger = logger
      @level = level
    end

    # write to the logger at level
    #
    # @param message [String] message to write to the logger
    def <<(message)
      @logger.log(@level, message)
    end

    # just-in-case, let's delegate anything else to the logger
    def method_missing(m, *args, &block)
      if @logger.respond_to?(m)
        @logger.send(m, *args, &block)
      else
        super
      end
    end

    # ensure that logger can handle the missing method
    def respond_to_missing?(m, *)
      @logger.respond_to?(m) || super
    end
  end
end
