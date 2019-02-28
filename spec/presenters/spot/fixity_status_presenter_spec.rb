# frozen_string_literal: true
RSpec.describe Spot::FixityStatusPresenter do
  subject(:presenter) { described_class.new(id) }

  let(:id) { 'abc123' }

  before do
    ChecksumAuditLog.create!(passed: true,
                             checked_uri: 'http://example.org/fs/id',
                             file_set_id: id,
                             file_id: 'afile',
                             expected_result: 'abc123def456ghi789')
  end

  describe '#summary' do
    subject { presenter.summary }

    it { is_expected.to include '1 File with 1 total version checked' }
  end

  describe '#log_records' do
    subject { presenter.log_records }

    it { is_expected.to be_an ActiveRecord::Relation }
  end
end
