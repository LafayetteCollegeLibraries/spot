# frozen_string_literal: true
RSpec.describe Spot::EmbargoLeaseService, valkyrization: true do
  # testing on a Publication, but theoretically this should behave the same on all resources.
  # since we're not validating the resources, we don't really need metadata.
  let(:original_resource) { FactoryBot.valkyrie_create(:publication_resource_with_required_fields_only) }
  let(:resource) { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: original_resource.id) }
  let(:embargo) { FactoryBot.valkyrie_create(:embargo, embargo_release_date: embargo_release_date) }
  let(:lease) { FactoryBot.valkyrie_create(:lease, lease_expiration_date: lease_expiration_date) }
  let(:embargo_release_date) { DateTime.now.utc + 1.day }
  let(:lease_expiration_date) { DateTime.now.utc + 1.day }

  describe '.clear_all_expired' do
    describe 'embargoes' do
      # @note In Hyrax < 5.0.1 there's not a way to use the Wings persister without triggering
      #       ActiveFedora validations (which will ultimately not allow an Embargo to be applied
      #       with a date in the past), so instead we'll cast the Resource + Embargo/Leases to
      #       ActiveFedora objects and assign the Embargo/Lease that way, allowing us to call
      #       #save(validate: false).
      #
      # @todo When we upgrade to Hyrax 5.0.1, we should be able to replace this block with:
      #       before do
      #         resource.embargo = embargo
      #         Hyrax.persister.save(resource: resource, perform_af_validation: false)
      #       end
      before do
        af_resource = Hyrax.persister.resource_factory.from_resource(resource: resource)
        af_embargo = Hyrax.persister.resource_factory.from_resource(resource: embargo)
        af_resource.visibility = af_embargo.visibility_during_embargo
        af_resource.embargo = af_embargo
        af_resource.save(validate: false)
      end

      after do
        Hyrax.persister.delete(resource: original_resource)
      end

      context 'with an active embargo' do
        let(:embargo_release_date) { DateTime.now.utc + 1.day }

        it 'does nothing' do
          expect { described_class.clear_all_expired }
            .not_to change { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: resource.id).visibility }
        end
      end

      context 'with an expired embargo' do
        let(:embargo_release_date) { DateTime.now.utc - 1.day }

        it "updates the item's visibility" do
          expect { described_class.clear_all_expired }
            .to change { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: resource.id).visibility }
            .from(embargo.visibility_during_embargo)
            .to(embargo.visibility_after_embargo)
        end

        context 'for a resource with children' do
          let(:resource) { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: original_resource.id) }
          let(:child) { FactoryBot.valkyrie_create(:publication_resource_with_required_fields_only) }
          let(:child_resource) { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: child.id) }

          before do
            allow(Hyrax::AccessControlList).to receive(:copy_permissions)

            resource.member_ids << child_resource.id
            Hyrax.persister.save(resource: resource)
          end

          # @todo having difficulty getting children to save reliably to test?
          skip 'calls Hyrax::AccessControlList.copy_permissions for each child' do
            expect(Hyrax.query_service.find_members(resource: resource).count).not_to be_zero

            described_class.clear_all_expired

            expect(Hyrax::AccessControlList)
              .to have_received(:copy_permissions)
              .with(source: resource, target: child_resource)
              .exactly(1).time
          end
        end
      end
    end

    describe 'leases' do
      # @see above before block
      before do
        af_resource = Hyrax.persister.resource_factory.from_resource(resource: resource)
        af_lease = Hyrax.persister.resource_factory.from_resource(resource: lease)
        af_resource.lease = af_lease
        af_resource.visibility = af_lease.visibility_during_lease
        af_resource.save(validate: false)
      end

      context 'with an expired lease' do
        let(:lease_expiration_date) { DateTime.now.utc - 1.day }

        it "updates the item's visibility" do
          expect { described_class.clear_all_expired }
            .to change { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: resource.id).visibility }
            .from(lease.visibility_during_lease)
            .to(lease.visibility_after_lease)
        end
      end

      context 'with an active lease' do
        let(:lease_expiration_date) { DateTime.now.utc + 1.day }

        it 'does nothing' do
          expect { described_class.clear_all_expired }
            .not_to change { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: resource.id).visibility }
        end
      end
    end
  end
end
