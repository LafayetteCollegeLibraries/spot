# frozen_string_literal: true
#
# rubocop:disable RSpec/InstanceVariable
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'SPOT one step workflow', :perform_jobs, :clean, :js do
  let(:depositing_user) { FactoryBot.create(:user) }
  let(:admin_user) { FactoryBot.create(:admin_user) }
  let(:publication) { FactoryBot.actor_create(:publication, :public, user: depositing_user) }

  before do
    admin_set = AdminSet.find(AdminSet.find_or_create_default_admin_set_id)
    @previous_workflow = admin_set.permission_template.active_workflow
    processing_wf = admin_set.permission_template.available_workflows.find_by_name('spot_one_step_process')
    Sipity::Workflow.activate!(permission_template: admin_set.permission_template, workflow_id: processing_wf.id)
  end

  after do
    admin_set = AdminSet.first
    processing_wf = admin_set.permission_template.available_workflows.find_by_name(@previous_workflow.name)
    Sipity::Workflow.activate!(permission_template: admin_set.permission_template, workflow_id: processing_wf.id)
  end

  context 'a logged in user' do
    scenario "a user submits a publication and an admin approves it", js: true do
      expect(publication.active_workflow.name).to eq "spot_one_step_process"
      expect(publication.to_sipity_entity.reload.workflow_state_name).to eq "processing"

      # Check workflow permissions for depositing user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: depositing_user, entity: publication.to_sipity_entity)
                                                                   .pluck(:name)
      expect(available_workflow_actions).to be_empty

      # Visit the work as a public user. It should not be visible.
      logout
      visit("/catalog?utf8=✓&search_field=all_fields&q=")
      expect(page).not_to have_content publication.title.first

      # Publication should be visible and downloadable by the depositor
      login_as depositing_user
      visit("/concern/publications/#{publication.id}")
      expect(page).to have_content(publication.title.first)

      # Check workflow permissions for admin user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: admin_user, entity: publication.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("approve")).to eq true
      expect(available_workflow_actions.include?("request_changes")).to eq false
      expect(available_workflow_actions.include?("comment_only")).to eq false

      # See works under review in the dashboard
      login_as admin_user
      visit '/admin/workflows?locale=en#under-review'
      expect(page).to have_content(publication.title.first)

      # The admin user marks the publication as approved
      subject = Hyrax::WorkflowActionInfo.new(publication, admin_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      expect(publication.to_sipity_entity.reload.workflow_state_name).to eq "processed"

      # Visit the work as a public user. It should be visible.
      logout
      visit("/concern/publications/#{publication.id}")
      expect(page).to have_content publication.title.first
      expect(page).to have_content publication.description.first
    end
  end
end
# rubocop:enable RSpec/InstanceVariable
