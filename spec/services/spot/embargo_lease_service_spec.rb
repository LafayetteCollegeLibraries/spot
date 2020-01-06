# frozen_string_literal: true
RSpec.describe Spot::EmbargoLeaseService do
  describe '.clear_expired_embargoes' do
    let(:publication) do
      @publication ||= begin
        build(:publication).tap do |pub|
          pub.embargo = embargo
          pub.admin_set_id = AdminSet.find_or_create_default_admin_set_id
          pub.save(validate: false)
        end
      end
    end

    let(:visibility_during_embargo) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    let(:visibility_after_embargo) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let(:release_date) { Date.yesterday.to_s }

    let(:embargo) do
      Hydra::AccessControls::Embargo.create(
        visibility_during_embargo: visibility_during_embargo,
        visibility_after_embargo: visibility_after_embargo,
        embargo_release_date: release_date
      )
    end

    # it do
    #   byebug
    # end
  end

  # we just want to be sure that the methods are being called, so
  # let's just mock everything
  describe '.clear_all_expired' do
    let(:embargoed_presenter) { instance_double(Hyrax::WorkShowPresenter, id: 'abc123def') }
    let(:leased_presenter) { instance_double(Hyrax::WorkShowPresenter, id: 'def456ghi') }
    let(:embargoed_work) { instance_double(Publication) }
    let(:leased_work) { instance_double(Publication) }
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
        .and_return(embargoed_work)

      allow(ActiveFedora::Base)
        .to receive(:find)
        .with(leased_presenter.id)
        .and_return(leased_work)

      allow(Hyrax::Actors::EmbargoActor)
        .to receive(:new)
        .with(embargoed_work)
        .and_return(embargoed_actor_double)

      allow(Hyrax::Actors::LeaseActor)
        .to receive(:new)
        .with(leased_work)
        .and_return(leased_actor_double)

      allow(embargoed_work).to receive(:date_available=)
    end

    it 'calls destroy on both the embargo + lease actors' do
      described_class.clear_all_expired

      expect(embargoed_work).to have_received(:date_available=).with([todays_date])
      expect(embargoed_actor_double).to have_received(:destroy).exactly(1).time
      expect(leased_actor_double).to have_received(:destroy).exactly(1).time
    end
  end
end
