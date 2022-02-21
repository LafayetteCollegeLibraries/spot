# frozen_string_literal: true
RSpec.describe Spot::Workflow::AdvisorRequestsChangesNotification do
  it_behaves_like 'a Spot::Workflow notification' do
    let(:subject_line) { 'Changes Required' }
    let(:message) do
      "A submission you recently deposited (<em><a href=\"/concern/student_works/#{workflow_object.id}\">#{workflow_object.title.first}</a></em>) " \
        "has been reviewed by #{workflow_action_user.display_name} and requires the following changes: " \
        "<blockquote>#{workflow_comment.gsub(/\n/, '<br>')}</blockquote>"
    end
    let(:recipients) { [depositing_user] }
  end
end
