# frozen_string_literal: true
RSpec.describe User do
  let(:user) { create(:user, **extra_attributes) }
  let(:extra_attributes) { {} }

  describe '#to_s' do
    subject { user.to_s }

    it { is_expected.to eq user.email }
  end

  describe '#cas_extra_attributes=' do
    before { user.cas_extra_attributes = attrs }

    let(:attrs) do
      {
        'lnumber' => 'L00000000',
        'uid' => 'wishmand',
        'givenName' => 'Doris',
        'surname' => 'Wishman',
        'email' => 'wishmand@lafayette.edu',
        'eduPersonEntitlement' => entitlements
      }
    end
    let(:entitlements) { ['https://ldr.lafayette.edu/'] }

    it 'sets "uid" as #username' do
      expect(user.username).to eq attrs['uid']
    end

    it 'sets the email' do
      expect(user.email).to eq attrs['email']
    end

    it 'sets the L-number' do
      expect(user.lnumber).to eq attrs['lnumber']
    end

    it 'sets the given_name' do
      expect(user.given_name).to eq attrs['givenName']
    end

    it 'sets the surname' do
      expect(user.surname).to eq attrs['surname']
    end

    # meta-programming user groups
    %w[student faculty staff alumni].each do |entitlement|
      context %(when a "#{entitlement}" entitlement is present) do
        let(:entitlements) { ["https://ldr.lafayette.edu/#{entitlement}"] }

        it "adds the user to the #{entitlement} group" do
          expect(user.send(:"#{entitlement}?")).to be true
        end
      end
    end
  end

  describe '#authority_name' do
    subject { user.authority_name }

    it { is_expected.to eq "#{user.surname}, #{user.given_name}" }

    context 'when "given_name" not present' do
      let(:extra_attributes) { { given_name: nil, surname: 'spot' } }

      it { is_expected.to eq 'spot' }
    end

    context 'when surname not present' do
      let(:extra_attributes) { { given_name: 'DeposiBot', surname: nil } }

      it { is_expected.to eq 'DeposiBot' }
    end
  end

  describe '#display_name' do
    subject { user.display_name }

    it { is_expected.to eq "#{user.given_name} #{user.surname}" }

    context 'when "given_name" not present' do
      let(:extra_attributes) { { given_name: nil, surname: 'spot' } }

      it { is_expected.to eq 'spot' }
    end

    context 'when surname not present' do
      let(:extra_attributes) { { given_name: 'DeposiBot', surname: nil } }

      it { is_expected.to eq 'DeposiBot' }
    end
  end

  describe '#ensure_username (before_save callback)' do
    let(:user) { described_class.new(email: 'cool_beans@lafayette.edu') }

    it 'creates a username where missing' do
      expect(user.username).to be nil
      user.save!
      expect(user.username).to eq 'cool_beans'
    end
  end
end
