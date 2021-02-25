# frozen_string_literal: true
RSpec.shared_examples 'it includes Spot::WorkBehavior' do
  subject { described_class.new }

  # mixins
  it_behaves_like 'a model with hyrax core metadata'
  it_behaves_like 'it ensures the existence of a NOID identifier'
  it_behaves_like 'it includes Spot::CoreMetadata'
  it_behaves_like 'it accepts "metadata" as a visibility'

  # validations
  it_behaves_like 'it validates field presence', field: :title
  it_behaves_like 'it validates field presence', field: :resource_type, value: ['Image']
  it_behaves_like 'it validates field presence', field: :rights_statement
  it_behaves_like 'it validates local authorities', field: :resource_type, authority: 'resource_types'
  it_behaves_like 'it validates local authorities', field: :rights_statement, authority: 'rights_statements'

  # unique behaviors
  describe '.controlled_properties (class_attribute)' do
    subject { described_class }

    it { is_expected.to respond_to(:controlled_properties) }
    it { is_expected.to respond_to(:controlled_properties=) }
  end
end
