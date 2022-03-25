# frozen_string_literal: true
RSpec.describe Spot::Workflow::ActivateObject do
  subject { described_class.call(target: work) }

  before do
    allow(Hyrax::Workflow::ActivateObject).to receive(:call).with(target: work).and_return true
  end

  let(:work) { build(:student_work) }

  it 'calls Hyrax::Workflow::ActivateObject' do
    described_class.call(target: work)
    expect(Hyrax::Workflow::ActivateObject).to have_received(:call).with(target: work)
  end

  # truthy values will result in a saved `target`
  it { is_expected.to be_truthy }

  context 'when a model has a :date_available property' do
    let(:work) { build(:student_work, date_available: [], embargo_release_date: date) }
    let(:date) { nil }

    context 'when an embargo is set' do
      let(:date) { Date.new(2125, 2, 11) }

      it 'sets :date_available to the date formatted as YYYY-MM-DD' do
        expect { described_class.call(target: work) }
          .to change { work.date_available.to_a }
          .from([])
          .to(['2125-02-11'])
      end
    end

    context 'when no embargo is set' do
      before do
        allow(Time.zone).to receive(:now).and_return(Time.new(2022, 3, 25))
      end

      it 'sets :date_available to Time.zone.now, formatted as YYYY-MM-DD' do
        expect { described_class.call(target: work) }
          .to change { work.date_available.to_a }
          .from([])
          .to(['2022-03-25'])
      end
    end

    context 'when a value already exists' do
      let(:work) { build(:student_work, date_available: ['1986-02-11']) }

      it 'retains the value' do
        described_class.call(target: work)

        expect(work.date_available).to eq ['1986-02-11']
      end
    end
  end

  context 'when a model does not have a :date_available property' do
    let(:work) { build(:image) }

    it { is_expected.to be_truthy }
  end
end
