# frozen_string_literal: true
RSpec.describe Spot::SendFixityStatusJob do
  subject(:perform_job!) do
    described_class.perform_now(item_count: item_count, job_time: job_time)
  end

  before do
    allow(Slack::Web::Client).to receive(:new).and_return(slack_client)
    ChecksumAuditLog.find_or_create_by(file_set_id: 'ab12', passed: false)
  end

  let(:slack_client) { instance_double('Slack::Web::Client', post: true) }
  let(:item_count) { 100 }
  let(:job_time) { 25 }

  context 'when no ENV variables are defined' do
    before { perform_job! }

    it 'does not invoke the Slack client' do
      expect(slack_client).not_to have_received(:post)
    end
  end

  context 'when ENV variables are defined' do
    before do
      stub_env('SLACK_API_TOKEN', 'abc123')
      stub_env('SLACK_FIXITY_CHANNEL', '#the-cool-zone')

      perform_job!
    end

    let(:expected_args) do
      [
        'chat.postMessage',
        {
          channel: '#the-cool-zone',
          blocks: JSON.dump([{
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: 'Performed 100 fixity checks in 25 seconds on ' \
                    "`#{`hostname`.chomp}`"
            },
            fields: [
              { type: 'mrkdwn',     text: ':white_check_mark: *Successes*' },
              { type: 'mrkdwn',     text: ':warning: *Failures*' },
              { type: 'plain_text', text: '99' },
              { type: 'plain_text', text: '1' }
            ]
          }]),
          as_user: true
        }
      ]
    end

    it 'does invokes the Slack client' do
      expect(slack_client)
        .to have_received(:post)
        .with(*expected_args)
    end
  end
end
