# frozen_string_literal: true
RSpec.describe Spot::StudentWorkFormHelper do
  describe '#form_tabs_for' do
    subject { helper.form_tabs_for(form: form) }

    let(:form_klass) { 'Hyrax::StudentWorkForm' }
    let(:form) { instance_double(form_klass) }
    let(:user) { create(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(user)

      # instance_double(form_klass).is_a?(Hyrax::StudentWorkForm) will always fail
      # because the double's class is RSpec::Mocks::InstanceVerifyingDouble, so we
      # need to tell the double how to do this
      allow(form)
        .to receive(:is_a?)
        .with(Hyrax::StudentWorkForm)
        .and_return(form_klass == 'Hyrax::StudentWorkForm')
    end

    context 'when the form is not a StudentWorkForm' do
      let(:form_klass) { 'Hyrax::PublicationForm' }

      it { is_expected.to eq %w[metadata files relationships] }
    end

    context 'when the user is an admin' do
      let(:user) { create(:admin_user) }

      it { is_expected.to eq %w[metadata files relationships] }
    end

    context 'when the user is not an admin' do
      it { is_expected.to eq %w[metadata files] }
    end
  end
end
