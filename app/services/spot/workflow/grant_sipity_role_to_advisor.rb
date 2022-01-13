# frozen_string_literal: true
module Spot
  module Workflow
    class GrantSipityRoleToAdvisor
      def self.call(target:, **)
        new(target: target).grant!
      end

      def initialize(target:)
        @target = target
      end

      def grant!
        Sipity::EntitySpecificResponsibility.find_or_create_by!(workflow_role: workflow_role, entity: entity, agent: agent)
      end

      private

      def advisor_from_target
        lnumber = @target.advisor.first
        User.find_by(lnumber: lnumber)
      end

      def agent
        advisor_from_target.to_sipity_agent
      end

      def entity
        Sipity::Entity.find_or_create_by!(proxy_for_global_id: target_gid)
      end

      def target_gid
        @target.to_global_id.to_s
      end

      def workflow_role
        Sipity::Role[:advising]
      end
    end
  end
end
