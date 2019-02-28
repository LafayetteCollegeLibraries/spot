# frozen_string_literal: true
RSpec.describe Spot::FixityStatusPresenter do
  subject(:presenter) { described_class.new('abc123') }

  describe '#summary' do
    before { allow(presenter).to receive(:render_existing_check_summary) }

    it 'calls #render_existing_check_summary' do
      presenter.summary

      expect(presenter).to have_received(:render_existing_check_summary)
    end
  end

  describe '#log_records' do
    before { allow(presenter).to receive(:relevant_log_records) }

    it 'calls #relevant_log_records' do
      presenter.log_records

      expect(presenter).to have_received(:relevant_log_records)
    end
  end
end
