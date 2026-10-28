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

      def sipity_agents
        @target.advisor.map { |email| User.find_by(email: email).to_sipity_agent }
      end

      def sipity_entity
        Sipity::Entity.find_or_create_by!(proxy_for_global_id: target_gid)
      end

      def target_gid
        Hyrax::GlobalID(@target).to_s
      end

      def workflow_role
        workflow = Sipity::Workflow.find_active_workflow_for(admin_set_id: @target.admin_set_id)
        Sipity::WorkflowRole.find_or_create_by!(role: Sipity::Role[:advising], workflow: workflow)
      end
    end
  end
end
