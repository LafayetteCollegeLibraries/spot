# frozen_string_literal: true
RSpec.describe Spot::SyncCollectionPermissionsJob do
  let(:collection) { instance_double(Collection, id: collection_id, permission_template: permission_template) }
  let(:collection_id) { 'sync-collection.id' }

  let(:admin) { Ability.admin_group_name }
  let(:permission_template) { Hyrax::PermissionTemplate.create(source_id: collection_id, access_grants: grants) }
  let(:grants) do
    [
      Hyrax::PermissionTemplateAccess.create(agent_id: 'cool-group', agent_type: 'group', access: 'manage'),
      Hyrax::PermissionTemplateAccess.create(agent_id: 'user@lafayette.edu', agent_type: 'user', access: 'manage'),
      Hyrax::PermissionTemplateAccess.create(agent_id: 'public', agent_type: 'group', access: 'view'),
      Hyrax::PermissionTemplateAccess.create(agent_id: 'user@lafayette.edu', agent_type: 'user', access: 'view')
    ]
  end

  let(:item) do
    build(:image,
          edit_groups: [admin],
          edit_users: ['helper@lafayette.edu'],
          read_groups: [admin],
          read_users: ['helper@lafayette.edu'])
  end

  before do
    allow(item).to receive(:save)
    allow(ActiveFedora::Base)
      .to receive(:where)
      .with(member_of_collection_ids_ssim: collection_id)
      .and_return([item])
  end

  after { permission_template.destroy! }

  # rubo wants us to align +.and+ with the previous line's +.from+, which doesn't read correctly
  #
  # rubocop:disable Layout/MultilineMethodCallIndentation
  context 'default behavior' do
    it 'adds the permission_templates grants to the item' do
      expect { described_class.perform_now(collection) }
        .to change { item.edit_groups }.from([admin]).to([admin, 'cool-group'])
        .and change { item.edit_users  }.from(['helper@lafayette.edu']).to(['helper@lafayette.edu', 'user@lafayette.edu'])
        .and change { item.read_groups }.from([admin]).to([admin, 'public'])
        .and change { item.read_users  }.from(['helper@lafayette.edu']).to(['helper@lafayette.edu', 'user@lafayette.edu'])
    end
  end

  context 'with reset: true' do
    it "replaces the existing item permissions with the collection's" do
      expect { described_class.perform_now(collection, reset: true) }
        .to  change { item.edit_groups }.from([admin]).to(['cool-group'])
        .and change { item.edit_users  }.from(['helper@lafayette.edu']).to(['user@lafayette.edu'])
        .and change { item.read_groups }.from([admin]).to(['public'])
        .and change { item.read_users  }.from(['helper@lafayette.edu']).to(['user@lafayette.edu'])
    end
  end
  # rubocop:enable Layout/MultilineMethodCallIndentation
end
