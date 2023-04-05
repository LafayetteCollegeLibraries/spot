# frozen_string_literal: true
RSpec.describe Spot::LafayetteInstructorsAuthorityService do
  before do
    stub_env('LAFAYETTE_WDS_API_KEY', api_key)

    allow(Spot::LafayetteWdsService).to receive(:new).with(api_key: nil).and_return(wds_service)
    allow(Spot::LafayetteWdsService).to receive(:new).with(api_key: api_key).and_return(wds_service)
  end

  let(:local_auth) { Qa::LocalAuthority.find_or_create_by(name: described_class::SUBAUTHORITY_NAME) }
  let(:api_key) { 'abc123def!' }
  let(:wds_service) { instance_double(Spot::LafayetteWdsService) }

  describe '.label_for' do
    subject { described_class.label_for(email: email) }

    before do
      allow(wds_service).to receive(:person).with(email: email).and_return(wds_response)
    end

    let(:email) { 'malantoa@lafayette.edu' }
    let(:last_name) { 'Malantonio' }
    let(:first_name) { 'Anna' }
    let(:label) { "#{last_name}, #{first_name}" }
    let(:local_entry) { Qa::LocalAuthorityEntry.find_or_create_by(local_authority: local_auth, uri: email, label: label) }
    let(:wds_response) do
      {
        'EMAIL' => email.upcase,
        'LAST_NAME' => last_name,
        'FIRST_NAME' => first_name
      }
    end

    context 'when a QA entry exists in the database' do
      before do
        local_entry
        described_class.label_for(email: email)
      end

      it { is_expected.to eq label }

      it 'does not call the wds_service' do
        expect(wds_service).not_to have_received(:person)
      end
    end

    context 'when a QA entry exists in the database' do
      before { described_class.label_for(email: user.email) }

      let(:user) { create(:user, given_name: first_name, surname: last_name, email: email) }

      it { is_expected.to eq user.authority_name }

      it 'does not call the wds_service' do
        expect(wds_service).not_to have_received(:person)
      end
    end

    context 'when an entry does not exist in the database' do
      before { described_class.label_for(email: email) }

      it { is_expected.to eq label }

      it 'calls the wds_service' do
        expect(wds_service).to have_received(:person).with(email: email)
      end

      context 'when the response contains a preferred name' do
        let(:wds_response) do
          {
            'EMAIL' => email.upcase,
            'LAST_NAME' => last_name,
            'PREFERRED_FIRST_NAME' => 'Pref.',
            'FIRST_NAME' => first_name
          }
        end

        it { is_expected.to eq("#{last_name}, Pref.") }
      end
    end

    context 'when an email does not match' do
      let(:wds_response) { false }

      it 'creates a label with just the email address' do
        expect(described_class.label_for(email: email)).to eq(email)
      end
    end
  end

  describe '.load' do
    before do
      allow(wds_service).to receive(:instructors).with(term: term).and_return(instructors)
    end

    let(:term) { '202110' }
    let(:instructors) do
      [
        { 'EMAIL' => 'MALANTOA@LAFAYETTE.EDU', 'LAST_NAME' => 'Malantonio', 'FIRST_NAME' => 'Anna' },
        { 'EMAIL' => 'LAFAYETM@LAFAYETTE.EDU', 'LAST_NAME' => 'Lafayette', 'FIRST_NAME' => 'Mark' },
        { 'EMAIL' => 'NOODLEMI@LAFAYETTE.EDU', 'LAST_NAME' => 'Noodleman', 'FIRST_NAME' => 'Irene' }
      ]
    end

    it 'adds Qa::LocalAuthorityEntries for each returned person' do
      expect(described_class.load(term: term).map(&:uri)).to eq(instructors.map { |i| i['EMAIL'].downcase })
    end

    it 'creates User accounts for each entry' do
      expect(described_class.load(term: term).count)
        .to eq User.where(email: instructors.map { |i| i['EMAIL'].downcase }).count
    end

    context 'when an entry already exists' do
      before do
        entry = instructors.first
        Qa::LocalAuthorityEntry.find_or_create_by(local_authority: local_auth, uri: entry['EMAIL'].downcase, label: "#{entry['LAST_NAME']}, #{entry['FIRST_NAME']}")
      end

      it 'leaves it be' do
        expect(Qa::LocalAuthorityEntry.where(local_authority: local_auth).count).to eq 1
        expect(described_class.load(term: term).count).to eq instructors.count
        expect(Qa::LocalAuthorityEntry.where(local_authority: local_auth).count).to eq instructors.count
      end
    end

    context 'when an entry no longer is returned by the api' do
      let!(:entry) do
        Qa::LocalAuthorityEntry.find_or_create_by(local_authority: local_auth,
                                                  uri: 'deactivated@lafayette.edu',
                                                  label: 'Faculty, Retired',
                                                  active: true)
      end

      it 'does not mark it as active' do
        described_class.load(term: term)
        expect(entry.reload).not_to be_active
      end
    end
  end

  describe '#inspect' do
    subject { described_class.new(api_key: api_key).inspect }

    it { is_expected.not_to include(api_key) }
  end
end
