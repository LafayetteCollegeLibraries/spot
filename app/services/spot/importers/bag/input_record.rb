module Spot::Importers::Bag
  class InputRecord < Darlingtonia::InputRecord
    def self.from(metadata:, mapper: Spot::Importers::Bag::Mapper.new)
      mapper.metadata = metadata
      new(mapper: mapper)
    end
  end
end
