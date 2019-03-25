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
        'surname' => 'Wishman',
        'email' => 'wishmand@lafayette.edu'
      }
    end

    it 'stores "uid" as :username' do
      expect(user.username).to eq attrs['uid']
    end

    it 'stores the email' do
      expect(user.email).to eq attrs['email']
    end

    it 'constructs :display_name from "surname" + "givenName"' do
      expect(user.display_name).to eq "#{attrs['givenName']} #{attrs['surname']}"
    end

    context 'when "givenName" not present' do
      let(:attrs) { { 'uid' => 'spotapp', 'surname' => 'spot' } }

      it 'uses only the "surname"' do
        expect(user.display_name).to eq attrs['surname']
      end
    end
  end

  describe '#ensure_username (before_save callback)' do
    let(:user) { User.new(email: 'cool_beans@lafayette.edu') }

    it 'creates a username where missing' do
      expect(user.username).to be nil
      user.save!
      expect(user.username).to eq 'cool_beans'
    end
  end
end
