# frozen_string_literal: true
RSpec.describe Spot::SyncCollectionPermissionsJob, valkyrization: true do
  let(:collection) { instance_double(Collection, id: collection_id, permission_template: permission_template) }
  let(:collection_id) { 'sync-collection--id' }

  let(:user) { create(:user) }
  let(:helper_user) { create(:user) }
  let(:admin_group) { Ability.admin_group_name }
  let(:permission_template) { Hyrax::PermissionTemplate.create(source_id: collection_id, access_grants: grants) }
  let(:grants) do
    [
      Hyrax::PermissionTemplateAccess.create(agent_id: 'another_group', agent_type: 'group', access: 'manage'),
      Hyrax::PermissionTemplateAccess.create(agent_id: user.email, agent_type: 'user', access: 'manage'),
      Hyrax::PermissionTemplateAccess.create(agent_id: 'public', agent_type: 'group', access: 'view'),
      Hyrax::PermissionTemplateAccess.create(agent_id: user.email, agent_type: 'user', access: 'view')
    ]
  end

  let(:item) { FactoryBot.valkyrie_create(:publication_resource_with_required_fields_only) }

  before do
    allow(Hyrax.query_service.custom_queries).to receive(:find_members_of).with(collection: collection).and_return([item])
  end

  after do
    permission_template.destroy!
    Hyrax.persister.delete(resource: item)
  end

  context 'default behavior' do
    before do
      # reset initial permissions
      item.edit_groups = [admin_group]
      item.edit_users = [helper_user.email]
      item.permission_manager.acl.save
    end

    it 'updates the work\'s edit_groups and edit_users' do
      expect { described_class.perform_now(collection) }
        .to change { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: item.id).edit_groups.to_a }
        .from([admin_group])
        .to([admin_group, 'another_group'])
        .and change { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: item.id).edit_users.to_a }
        .from([helper_user.email])
        .to([helper_user.email, user.email])
    end
  end

  context 'with reset: true' do
    let(:yet_another_user) { create(:user) }

    before do
      # reset to different defaults
      item.edit_groups = [admin_group, 'a wholly different edit group']
      item.edit_users = [yet_another_user.email]
      item.permission_manager.acl.save
    end

    it 'removes the previous edit_groups and edit_users' do
      expect { described_class.perform_now(collection, reset: true) }
        .to change { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: item.id).edit_groups.to_a }
        .from([admin_group, 'a wholly different edit group'])
        .to(['another_group'])
        .and change { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: item.id).edit_users.to_a }
        .from([yet_another_user.email])
        .to([user.email])
    end
  end
end
