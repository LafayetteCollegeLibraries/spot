shared_examples 'a mapped field' do
  let(:value) { ['some value'] }
  let(:metadata) { {field => value} }

  it { is_expected.to eq value }
end
