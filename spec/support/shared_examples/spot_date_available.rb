# frozen_string_literal: true
RSpec.shared_examples 'it includes Spot::DateAvailable' do
  let(:work) { described_class.new(attributes) }
  let(:attributes) { attributes_for(factory, date_available: []) }
  let(:factory) { described_class.name.underscore.to_sym }

  it { is_expected.to have_editable_property(:date_available).with_predicate(RDF::Vocab::DC.available) }

  describe '#set_date_available!' do
    # probably a no-no (mocking the subject) but this method calls #save!
    # and i'd like to cut back on the data persisted (not to mention
    # validations failing, whichis out of scope for these tests)
    before { allow(work).to receive(:save!) }

    context 'when no embargo set (default behavior)' do
      before do
        allow(Time.zone).to receive(:now).and_return(Time.new(2022, 3, 14) )
      end

      it "sets the value to today's date as YYYY-MM-DD" do
        # NOTE: we need to cast #date_available to an array because it's actually
        # an ActiveTriples::Relation, and using it within the change block will
        # not register that the change has occurred (the old_value and new_value will
        # point at the same object, failing an inequality check)
        expect { work.set_date_available! }
          .to change { work.date_available.to_a }
          .from([])
          .to(['2022-03-14'])

        expect(work).to have_received(:save!)
      end
    end

    context 'when an embargo_release_date is present' do
      let(:attributes) { attributes_for(factory, date_available: [], embargo_release_date: date) }
      let(:date) { Date.new(2022, 3, 11) }

      it 'sets the value to the embargo_release_date as YYYY-MM-DD' do
        expect { work.set_date_available! }
          .to change { work.date_available.to_a }
          .from([])
          .to(['2022-03-11'])

        expect(work).to have_received(:save!)
      end
    end
  end
end
