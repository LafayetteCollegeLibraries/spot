shared_examples 'a mapped field' do
  subject { mapper.send(method) }

  let(:value) { ['some value'] }
  let(:metadata) { {field => value} }

  it { is_expected.to eq value }
end
