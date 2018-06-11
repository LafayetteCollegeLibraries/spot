module Spot
  class DepartmentAuthorities < ::Hyrax::QaSelectService
    def initialize
      super('lafayette_departments')
    end
  end
end
