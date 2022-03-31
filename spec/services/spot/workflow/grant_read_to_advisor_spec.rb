# frozen_string_literal: true
RSpec.describe Spot::Workflow::GrantReadToAdvisor do
  let(:workflow_method) { described_class }
  let(:advisor) { create(:user) }
  let(:depositor) { create(:user) }
  let(:work) { build(:student_work, id: 'abc123', advisor: [advisor_key], user: depositor) }

  before do
    stub_env('LAFAYETTE_WDS_API_KEY', 'abc123def!')

    allow(Spot::LafayetteInstructorsAuthorityService)
      .to receive(:label_for)
      .with(email: advisor.email)
      .and_return('Advisor, Faculty')
  end

  it_behaves_like 'a Hyrax workflow method'

  let(:advisor_key) { advisor.email }

  it "adds the advisor to the work's #read_users" do
    expect { described_class.call(target: work) }
      .to change { work.read_users }.from([]).to([advisor.user_key])
  end

  context 'when the work does not have an "advisor" field' do
    subject { described_class.call(target: work) }

    let(:work) { build(:publication, id: 'cba321') }

    it { is_expected.to be nil }
  end

  context 'when the advisor User can not be found' do
    subject { described_class.call(target: work) }

    let(:advisor_key) { 'Joe Faculty' }

    it { is_expected.to be nil }
  end
end
