# frozen_string_literal: true
RSpec.describe Spot::ContactHelper do
  describe '.repository_librarian_name_and_title' do
    subject { helper.repository_librarian_name_and_title }

    let(:librarian_name) { 'Anne Librarian' }
    let(:librarian_title) { 'Digital Repository Librarian' }

    before do
      allow(I18n).to receive(:t).with('spot.contact.repository_librarian.name', default: nil).and_return(librarian_name)
      allow(I18n).to receive(:t).with('spot.contact.repository_librarian.title', default: nil).and_return(librarian_title)
    end

    context 'when both name + title are present' do
      it { is_expected.to eq "#{librarian_name}, #{librarian_title}" }
    end

    context 'when just name is present' do
      let(:librarian_title) { nil }

      it { is_expected.to eq librarian_name }
    end

    context 'when just the title is present' do
      let(:librarian_name) { nil }

      it { is_expected.to eq "our #{librarian_title}" }
    end

    context 'when neither name nor title are present' do
      let(:librarian_name) { nil }
      let(:librarian_title) { nil }

      it { is_expected.to eq 'us' }
    end
  end

  describe '.repository_copyright_contact_mailto_link' do
    subject { helper.repository_copyright_contact_mailto_link }

    let(:email) { 'copyright@lafayette.edu' }
    let(:department_email) { 'dss@lafayette.edu' }
    let(:email_link) { %(<a href="mailto:#{email}">#{email}</a>)}

    before do
      allow(I18n).to receive(:t).with('spot.contact.department.email').and_return(department_email)
      allow(I18n).to receive(:t).with('spot.contact.copyright.email', default: department_email).and_return(email)
    end

    context 'when a copyright contact translation value is present' do
      it { is_expected.to eq email_link }
    end

    context 'when the copyright contact is empty' do
      let(:email) { department_email } # this is our fallback

      it { is_expected.to eq email_link }
    end
  end

  describe '.repository_librarian_mailto_link' do
    subject { helper.repository_librarian_mailto_link }

    let(:email) { 'repository_librarian@lafayette.edu' }
    let(:department_email) { 'dss@lafayette.edu' }
    let(:email_link) { %(<a href="mailto:#{email}">#{email}</a>)}

    before do
      allow(I18n).to receive(:t).with('spot.contact.department.email').and_return(department_email)
      allow(I18n).to receive(:t).with('spot.contact.repository_librarian.email', default: department_email).and_return(email)
    end

    context 'when a repository_librarian email is present' do
      it { is_expected.to eq email_link }
    end

    context 'when falling back to default' do
      let(:email) { department_email }

      it { is_expected.to eq email_link }
    end
  end

  describe '.repository_contact_mailto_link' do
    subject { helper.repository_contact_mailto_link }

    let(:email) { 'repository@lafayette.edu' }
    let(:department_email) { 'dss@lafayette.edu' }
    let(:email_link) { %(<a href="mailto:#{email}">#{email}</a>)}

    before do
      allow(I18n).to receive(:t).with('spot.contact.department.email').and_return(department_email)
      allow(I18n).to receive(:t).with('spot.contact.repository.email', default: department_email).and_return(email)
    end

    context 'when a repository_librarian email is present' do
      it { is_expected.to eq email_link }
    end

    context 'when falling back to default' do
      let(:email) { department_email }

      it { is_expected.to eq email_link }
    end
  end
end
