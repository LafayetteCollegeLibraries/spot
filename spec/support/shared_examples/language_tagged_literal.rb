# frozen_string_literal: true
# can shared examples be nested? it feels redundant to have these
# two split when the only difference is the +:params+ hash.

shared_examples 'a parsed language-tagged literal (single)' do
  subject { attributes[field] }

  let(:params) do
    {
      "#{field}_value" => 'Terminator 2: Judgement Day',
      "#{field}_language" => 'en'
    }
  end

  it { is_expected.to eq ['"Terminator 2: Judgement Day"@en'] }
end

shared_examples 'a parsed language-tagged literal (multiple)' do
  subject { attributes[field] }

  let(:params) do
    {
      "#{field}_value" => ['Exorcist, the', 'L\'exorciste', ''],
      "#{field}_language" => ['', 'fr', '']
    }
  end

  let(:tagged_literals) do
    ['"Exorcist, the"', '"L\'exorciste"@fr']
  end

  it { is_expected.to eq tagged_literals }
end
