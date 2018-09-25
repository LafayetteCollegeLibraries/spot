module Spot
  class AcademicDepartmentAuthorities < ::Hyrax::QaSelectService
    def initialize
      super('lafayette_departments')
    end
  end
end
