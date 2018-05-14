shared_examples 'a read and writable multiple property' do
  let(:value) { ['Example value'] }

  it 'reads and writes values' do
    expect(subject).to be_empty
    subject = value
    expect(subject).to eq value
  end
end
