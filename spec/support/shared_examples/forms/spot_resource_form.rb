# frozen_string_literal: true
RSpec.shared_examples 'a Spot resource form' do
  let(:form) { described_class.new(resource) }
  let(:resource) { resource_class.new }
  let(:resource_class) { described_class.name.split('::').last.gsub(/Form$/, '').constantize }

  skip '#primary_terms' do
    # how to test this per resource?
  end

  describe '#secondary_terms' do
    subject { form.secondary_terms }

    # it { is_expected.to be_empty }
  end
end
