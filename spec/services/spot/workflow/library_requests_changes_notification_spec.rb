# frozen_string_literal: true
RSpec.describe Spot::Workflow::LibraryRequestsChangesNotification do
  it_behaves_like 'a Spot::Workflow notification' do
    let(:subject_line) { 'Submission requires changes' }
    let(:message) do
      "Library staff have reviewed <em><a href=\"/concern/student_works/#{workflow_object.id}\">#{workflow_object.title.first}</a></em> " \
        "and request the following changes:<blockquote>#{workflow_comment_html}</blockquote>" \
        "Please make the changes and update the Review and Approval form at the top of the page."
    end
  end
end
