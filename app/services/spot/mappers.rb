# frozen_string_literal: true
#
# This might be a bit overkill, but I wanted to extract the +available_mappers+
# listing from {Spot::IngestZippedBag}, which isn't the appropriate place for it.
# Add mappers here to be able to select (via {.get}) within rake tasks.
module Spot
  module Mappers
    # @return [Hash<Symbol => Constant>]
    # rubocop:disable Metrics/MethodLength
    def self.available_mappers
      {
        alsace: AlsaceImagesMapper,
        cap: CapMapper,
        cpw_nofuko: CpwNofukoMapper,
        cpw_shashinkai: CpwShashinkaiMapper,
        gc_iroha: GcIrohaMapper,
        geology: GeologySlidesEsiMapper,
        imperial: ImperialPostcardsMapper,
        lewis: LewisPostcardsMapper,
        lin: LinPostcardsMapper,
        ldr: LdrDspaceMapper,
        magazine: MagazineMapper,
        mammana: MammanaPostcardsMapper,
        mckelvy: MckelvyHouseMapper,
        mdl_prints: MdlPrintsMapper,
        newspaper: NewspaperMapper,
        pa_koshitsu: PaKoshitsuMapper,
        pa_omitsu: PaOmitsuMapper,
        pa_tsubokura: PaTsubokuraMapper,
        pacwar: PacwarPostcardsMapper,
        rjw_stereo: RjwStereoMapper,
        shakespeare: ShakespeareBulletinMapper,
        tjwar: TjwarPostcardsMapper,
        war_casualties: WarCasualtiesMapper,
        warner_negs: WarnerNegsMapper,
        warner_postcards: WarnerPostcardsMapper,
        warner_souvenirs: WarnerSouvenirsMapper,
        woodsworth: WoodsworthImagesMapper
      }
    end
    # rubocop:enable Metrics/MethodLength

    # @param [String,Symbol] key
    # @return [Constant] mapper class for key
    def self.get(key)
      available_mappers[key.to_sym]
    end
  end
end
