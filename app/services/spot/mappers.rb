# frozen_string_literal: true
#
# This might be a bit overkill, but I wanted to extract the +available_mappers+
# listing from {Spot::IngestZippedBag}, which isn't the appropriate place for it.
# Add mappers here to be able to select (via {.get}) within rake tasks.
module Spot
  module Mappers
    # @return [Hash<Symbol => Constant>]
    def self.available_mappers
      {
        alsace: AlsaceImagesMapper,
        cpw_nofuko: CpwNofukoMapper,
        ldr: LdrDspaceMapper,
        magazine: MagazineMapper,
        newspaper: NewspaperMapper,
        pacwar: PacwarPostcardsMapper,
        rjw_stereo: RjwStereoMapper,
        shakespeare: ShakespeareBulletinMapper,
        warner_souvenirs: WarnerSouvenirsMapper,
        woodsworth: WoodsworthImagesMapper
      }
    end

    # @param [String,Symbol] key
    # @return [Constant] mapper class for key
    def self.get(key)
      available_mappers[key.to_sym]
    end
  end
end
