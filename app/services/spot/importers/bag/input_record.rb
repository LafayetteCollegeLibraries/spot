module Spot::Importers::Bag
  class InputRecord < Darlingtonia::InputRecord
    def self.from(metadata:, mapper: nil)
      raise 'Spot::Importers::Bag::InputRecord needs a mapper' if mapper.nil?
      mapper.metadata = metadata
      new(mapper: mapper)
    end
  end
end
