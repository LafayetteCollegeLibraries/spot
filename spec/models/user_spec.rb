# frozen_string_literal: true
RSpec.describe User do
  let(:user) { create(:user) }

  describe '#to_s' do
    subject { user.to_s }

    it { is_expected.to eq user.email }
  end

  describe '#cas_extra_attributes=' do
    before { user.cas_extra_attributes = attrs }

    let(:attrs) do
      {
        'uid' => 'wishmand',
        'givenName' => 'Doris',
        'sn' => 'Wishman'
      }
    end

    it 'stores "uid" as :username' do
      expect(user.username).to eq attrs['uid']
    end

    it 'constructs :display_name from "sn" + "givenName"' do
      expect(user.display_name).to eq "#{attrs['givenName']} #{attrs['sn']}"
    end

    context 'when "givenName" not present' do
      let(:attrs) { { 'uid' => 'spotapp', 'sn' => 'spot' } }

      it 'uses only the "sn"' do
        expect(user.display_name).to eq attrs['sn']
      end
    end
  end
end
