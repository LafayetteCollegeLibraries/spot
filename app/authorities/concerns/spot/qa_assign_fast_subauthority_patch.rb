# frozen_string_literal: true
module Spot
  module QaAssignFastSubauthorityPatch
    extend ActiveSupport::Concern

    def index_for_authority(authority)
      return authority if authority == 'idroot'

      Qa::Authorities::AssignFastSubauthority::SUBAUTHORITIES[authority]
    end

    def subauthorities
      Qa::Authorities::AssignFastSubauthority::SUBAUTHORITIES.keys + ['idroot']
    end
  end
end
