# frozen_string_literal: true
RSpec.describe AudioVisual do
  subject { described_class.new }

  it_behaves_like 'it includes Spot::WorkBehavior'

  # @todo might be useful to turn this into a shared_example?
  [
    [:date, RDF::Vocab::DC.date],
    [:embed_url, 'http://ldr.lafayette.edu/ns#embed_url']
  ].each do |(prop, uri)|
    it { is_expected.to have_editable_property(prop).with_predicate(uri) }
  end
end
