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
        sipity_agents.each do |agent|
          Sipity::EntitySpecificResponsibility.find_or_create_by!(workflow_role: workflow_role,
                                                                  entity: sipity_entity,
                                                                  agent: agent)
        end
      end

      private

      def advisor_from_target
        lnumber = @target.advisor.first.to_s

        case lnumber
        when /^L\d{8}$/
          User.find_by(lnumber: lnumber)
        when /^[^@]+@\w+\.\w+$/
          User.find_by(email: lnumber)
        end
      end

      def sipity_agents
        @target.advisor.map { |email| User.find_by(email: email).to_sipity_agent }
      end

      def sipity_entity
        Sipity::Entity.find_or_create_by!(proxy_for_global_id: target_gid)
      end

      def target_gid
        @target.to_global_id.to_s
      end

      def workflow_role
        Sipity::WorkflowRole.find_or_create_by!(role: Sipity::Role[:advising], workflow: @target.admin_set.active_workflow)
      end
    end
  end
end
