# frozen_string_literal: true
RSpec.describe Spot::SyncCollectionPermissionsJob, valkyrization: true do
  let(:collection) { instance_double(Collection, id: collection_id, permission_template: permission_template) }
  let(:collection_id) { 'sync-collection.id' }

  let(:user) { create(:user) }
  let(:helper_user) { create(:user) }
  let(:admin) { Ability.admin_group_name }
  let(:permission_template) { Hyrax::PermissionTemplate.create(source_id: collection_id, access_grants: grants) }
  let(:grants) do
    [
      Hyrax::PermissionTemplateAccess.create(agent_id: 'cool-group', agent_type: 'group', access: 'manage'),
      Hyrax::PermissionTemplateAccess.create(agent_id: user.email, agent_type: 'user', access: 'manage'),
      Hyrax::PermissionTemplateAccess.create(agent_id: 'public', agent_type: 'group', access: 'view'),
      Hyrax::PermissionTemplateAccess.create(agent_id: user.email, agent_type: 'user', access: 'view')
    ]
  end

  # the bare minimum to pass validation + save
  let(:item) do
    obj = ImageResource.new(
      title: ['Test Image Resource'],
      date: ['2024-11-26'],
      resource_type: ['Other'],
      rights_statement: ['http://rightsstatements.org/vocab/NKC/1.0/'],
      edit_groups: [admin],
      edit_users: [helper_user.email],
      read_groups: [admin],
      read_users: [helper_user.email]
    )
    Hyrax.persister.save(resource: obj)
  end

  let(:test_fcrepo_url) { "#{ENV['FEDORA_TEST_URL']}/test/sy/nc/-c/ol/sync-collection.id" }
  let(:valkyrie_solr_query) do
    %(+(member_of_collection_ids_ssim: "#{test_fcrepo_url}" OR member_of_collection_ids_ssim: "#{collection_id}"))
  end

  before do
    allow(collection).to receive(:reindex_extent=)
    allow(Hyrax.query_service.custom_queries).to receive(:find_members_of).with(collection: collection).and_return([item])
  end

  after do
    permission_template.destroy!
    Hyrax.persister.delete(resource: item)
  end

  context 'default behavior' do
    it 'adds the permission_templates grants to the item' do
      expect { described_class.perform_now(collection) }
        .to change { item.permission_manager.edit_groups }
        .from([admin]).to([admin, 'cool-group'])
        .and change { item.edit_users }.from([helper_user.email]).to([helper_user.email, user.email])
                                       .and change { item.read_groups }.from([admin]).to([admin, 'public'])
                                                                       .and change { item.read_users }.from([helper_user.email]).to([helper_user.email, user.email])
    end
  end

  context 'with reset: true' do
    it "replaces the existing item permissions with the collection's" do
      expect { described_class.perform_now(collection, reset: true) }
        .to change { item.edit_groups }
        .from([admin]).to(['cool-group'])
        .and change { item.edit_users }.from([helper_user.email]).to([user.email])
                                       .and change { item.read_groups }.from([admin]).to(['public'])
                                                                       .and change { item.read_users }.from([helper_user.email]).to([user.email])
    end
  end
end
