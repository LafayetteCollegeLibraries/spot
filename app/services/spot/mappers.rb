# frozen_string_literal: true
#
# This might be a bit overkill, but I wanted to extract this from
# {Spot::IngestZippedBag}, which isn't the appropriate place for it.
# Add mappers here to be able to select (via {.get}) within rake tasks.
module Spot
  module Mappers

    # @return [Hash<Symbol => Constant>]
    def self.available_mappers
      {
        ldr: LdrDspaceMapper,
        magazine: MagazineMapper,
        newspaper: NewspaperMapper,
        shakespeare: ShakespeareBulletinMapper
      }
    end

    # @param [String,Symbol] key
    # @return [Constant] mapper class for key
    def self.get(key)
      available_mappers[key.to_sym]
    end
  end
end
