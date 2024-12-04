# frozen_string_literal: true
#
# @note The Wings persister in Hyrax 3.6.0 doesn't allow for bypassing ActiveFedora validations
#       on #save (this isn't added until 5.0) so I'm using ActiveFedora manually to create the
#       resources with expired embargoes/leases. In theory this should be able to be set up by:
#         let(:resource) { create(:publication_resource) }
#         let(:embargo) { Hyrax::Embargo.new(visibility_during_embargo: 'restricted', visibility_after_embargo: 'open', embargo_release_date: Time.zone.yesterday) }
#         before do
#           resource.embargo = embargo
#           Hyrax.persister.save(resource: resource, perform_af_validation: false)
#         end
#
RSpec.describe Spot::EmbargoLeaseService, valkyrization: true do
  # testing on a Publication, but theoretically this should behave the same on all resources.
  # since we're not validating the resources, we don't really need metadata.
  let(:resource) { FactoryBot.valkyrie_create(:publication_resource_with_required_fields_only) }
  let(:queried_resource) { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: resource.id) }
  let(:embargo) { FactoryBot.valkyrie_create(:embargo, embargo_release_date: embargo_release_date) }
  let(:embargo_release_date) { Time.zone.tomorrow }

  before do
    resource.embargo = embargo
    af_object = Hyrax.persister.resource_factory.from_resource(resource: resource)
    af_object.save(validate: false)
  end

  after do
    Hyrax.persister.delete(resource: resource)
  end

  describe '.clear_expired_embargoes' do
    context 'with an expired embargo' do
      let(:embargo_release_date) { Time.zone.yesterday }

      it "updates the item's visibility" do
        expect { described_class.clear_expired_embargoes }
          .to change { resource.visibility }
          .from(embargo.visibility_during_embargo)
          .to(embargo.visibility_after_embargo)
      end
    end

    context 'with an active embargo' do
      let(:release_date) { Date.tomorrow.to_s }

      it 'does nothing' do
        expect { described_class.clear_expired_embargoes }
          .not_to change { resource.visibility }
      end
    end
  end

  skip '.clear_expired_leases' do
    before do

    end

    context 'with an expired lease' do
      let(:release_date) { Date.yesterday.to_s }

      it "updates the item's visibility" do
      end
    end

    context "when a lease isn't expired yet" do
      let(:release_date) { Date.tomorrow.to_s }

      it 'does nothing' do

      end
    end
  end

  # we just want to be sure that the methods are being called, so
  # let's just mock everything
  skip '.clear_all_expired' do

    before do

    end

    it 'calls destroy on both the embargo + lease actors' do

    end
  end
end
