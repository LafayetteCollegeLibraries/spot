# frozen_string_literal: true
RSpec.describe Spot::EmbargoLeaseService do
  let(:publication) { create(:publication) }
  let(:attributes) do
    { title: ['example item with an embargo'], date_issued: ['2020-01'],
      rights_statement: ['http://creativecommons.org/publicdomain/mark/1.0/'],
      resource_type: ['Other'], admin_set_id: AdminSet.find_or_create_default_admin_set_id }
  end

  describe '.clear_expired_embargoes' do
    let(:visibility_during_embargo) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    let(:visibility_after_embargo) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    before do
      publication.apply_embargo(Date.tomorrow.to_s, visibility_during_embargo, visibility_after_embargo)
      publication.embargo_release_date = release_date

      # need to skip validation so that we can back-date the embargo
      publication.save(validate: false)
    end

    context 'with an expired embargo' do
      let(:release_date) { Date.yesterday.to_s }

      it "updates the item's visibility" do
        expect(publication.visibility).to eq visibility_during_embargo

        described_class.clear_expired_embargoes

        # the same as +publication.reload+ but should be compatible with Wings
        expect(Publication.find(publication.id).visibility).to eq visibility_after_embargo
      end
    end

    context 'with an active embargo' do
      let(:release_date) { Date.tomorrow.to_s }

      it 'does nothing' do
        expect(publication.visibility).to eq visibility_during_embargo

        described_class.clear_expired_embargoes

        pub = Publication.find(publication.id)
        expect(pub.visibility).not_to eq visibility_after_embargo
        expect(pub.visibility).to eq visibility_during_embargo
      end
    end
  end

  describe '.clear_expired_leases' do
    let(:visibility_during_lease) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let(:visibility_after_lease) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    before do
      publication.apply_lease(Date.tomorrow.to_s, visibility_during_lease, visibility_after_lease)
      publication.lease_expiration_date = release_date
      publication.save(validate: false)
    end

    context 'with an expired embargo' do
      let(:release_date) { Date.yesterday.to_s }

      it "updates the item's visibility" do
        expect(publication.visibility).to eq visibility_during_lease

        described_class.clear_expired_leases

        expect(Publication.find(publication.id).visibility).to eq visibility_after_lease
      end
    end

    context "when a lease isn't expired yet" do
      let(:release_date) { Date.tomorrow.to_s }

      it 'does nothing' do
        expect(publication.visibility).to eq visibility_during_lease

        described_class.clear_expired_leases

        pub = Publication.find(publication.id)
        expect(pub.visibility).not_to eq visibility_after_lease
        expect(pub.visibility).to eq visibility_during_lease
      end
    end
  end

  # we just want to be sure that the methods are being called, so
  # let's just mock everything
  describe '.clear_all_expired' do
    let(:embargoed_presenter) { instance_double(Hyrax::WorkShowPresenter, id: 'abc123def') }
    let(:leased_presenter) { instance_double(Hyrax::WorkShowPresenter, id: 'def456ghi') }
    let(:publication_double) { instance_double(Publication, copy_visibility_to_files: true, save!: true) }
    let(:embargoed_actor_double) { instance_double(Hyrax::Actors::EmbargoActor, destroy: true) }
    let(:leased_actor_double) { instance_double(Hyrax::Actors::LeaseActor, destroy: true) }
    let(:todays_date) { Time.zone.now.strftime('%Y-%m-%d') }

    before do
      allow(Hyrax::EmbargoService)
        .to receive(:assets_with_expired_embargoes)
        .and_return([embargoed_presenter])

      allow(Hyrax::LeaseService)
        .to receive(:assets_with_expired_leases)
        .and_return([leased_presenter])

      allow(ActiveFedora::Base)
        .to receive(:find)
        .with(embargoed_presenter.id)
        .and_return(publication_double)

      allow(ActiveFedora::Base)
        .to receive(:find)
        .with(leased_presenter.id)
        .and_return(publication_double)

      allow(Hyrax::Actors::EmbargoActor)
        .to receive(:new)
        .with(publication_double)
        .and_return(embargoed_actor_double)

      allow(Hyrax::Actors::LeaseActor)
        .to receive(:new)
        .with(publication_double)
        .and_return(leased_actor_double)

      allow(publication_double).to receive(:date_available=)
    end

    it 'calls destroy on both the embargo + lease actors' do
      described_class.clear_all_expired

      expect(publication_double).to have_received(:date_available=).with([todays_date])
      expect(embargoed_actor_double).to have_received(:destroy).exactly(1).time
      expect(leased_actor_double).to have_received(:destroy).exactly(1).time
    end
  end
end
