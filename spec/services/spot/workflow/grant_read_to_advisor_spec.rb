# frozen_string_literal: true
RSpec.describe Spot::Workflow::GrantReadToAdvisor do
  let(:workflow_method) { described_class }

  it_behaves_like 'a Hyrax workflow method'
end
