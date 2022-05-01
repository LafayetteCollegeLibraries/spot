# frozen_string_literal: true
RSpec.describe Spot::Workflow::GrantReadToAdvisor do
  let(:workflow_method) { described_class }
  let(:advisors) { [create(:user), create(:user)] }
  let(:advisor_emails) { advisors.map(&:email) }
  let(:depositor) { create(:user) }
  let(:work) { build(:student_work, id: 'abc123', advisor: advisor_emails, user: depositor) }

  it_behaves_like 'a Hyrax workflow method'

  it "adds the advisor to the work's #read_users" do
    # using #sort bc the users aren't in the same order (sent to Hyrax::GrantReadToMembersJob,
    # which processes them last-in-first-out, i think)
    expect { described_class.call(target: work) }
      .to change { work.read_users.sort }
      .from([])
      .to(advisor_emails.sort)
  end

  context 'when the work does not have an "advisor" field' do
    subject { described_class.call(target: work) }

    let(:work) { build(:publication, id: 'cba321') }

    it { is_expected.to be nil }
  end

  context 'when the advisor User can not be found' do
    subject { described_class.call(target: work) }

    let(:advisor_emails) { ['not-here-anymore@example.org'] }

    it { is_expected.to be nil }
  end
end
