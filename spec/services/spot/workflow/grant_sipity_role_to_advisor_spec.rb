# frozen_string_literal: true
RSpec.describe Spot::Workflow::GrantSipityRoleToAdvisor do
  let(:workflow_method) { described_class }

  it_behaves_like 'a Hyrax workflow method'
end
