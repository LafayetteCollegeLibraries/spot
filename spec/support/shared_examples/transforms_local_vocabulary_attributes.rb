RSpec.shared_examples 'it transforms a local vocabulary attribute' do
  subject { attributes[field.to_s] }

  let(:attr_field) { "#{field}_attributes" }

  context "when passed nested_attributes" do
    let(:params) do
      {
        attr_field.to_s => {
          '0' => { 'id' => 'value1' },
          '1' => { 'id' => 'value2' }
        }
      }
    end

    it { is_expected.to eq %w(value1 value2) }
  end

  context 'when _destroy is passed' do
    let(:params) do
      {
        attr_field.to_s => {
          '0' => { 'id' => 'value1', '_destroy' => 'true' }
        }
      }
    end

    it { is_expected.to be_empty }
  end
end
