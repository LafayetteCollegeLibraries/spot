# frozen_string_literal: true
RSpec.describe Spot::WorkFormHelper do
  describe '#form_tabs_for' do
    subject { helper.form_tabs_for(form: form) }

    let(:form_klass) { 'Hyrax::PublicationForm' }
    let(:form) { form_klass.constantize.new(work, Ability.new(user), nil) }
    let(:user) { create(:user) }
    let(:factory_klass) { form_klass.constantize.model_class.to_s.underscore.to_sym }
    let(:work) { build(factory_klass) }
    let(:mocked_methods) { { new_record?: !work_persisted, persisted?: work_persisted, member_ids: work_member_ids } }
    let(:work_persisted) { false }
    let(:work_member_ids) { [] }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      mocked_methods.each_pair do |method, value|
        allow(work).to receive(method).and_return(value)
      end
    end

    RSpec.shared_examples 'it presents the standard form tabs' do
      context 'when the form is New' do
        it { is_expected.to eq %w[metadata files relationships] }
      end

      context 'when the form is Edit' do
        let(:work_persisted) { true }
        let(:work_member_ids) { ['abc123'] }

        it { is_expected.to eq %w[metadata files relationships media comments] }
      end
    end

    context 'when the form is a StudentWorkForm' do
      let(:form_klass) { 'Hyrax::StudentWorkForm' }

      context 'when the user is not an admin' do
        context 'when the form is New' do
          it { is_expected.to eq %w[metadata files] }
        end

        context 'when the form is Edit' do
          let(:work_persisted) { true }

          it { is_expected.to eq %w[metadata files comments] }
        end
      end

      context 'when the user is an admin' do
        let(:user) { create(:admin_user) }

        it_behaves_like 'it presents the standard form tabs'
      end
    end

    context 'when the form is a BatchUploadForm' do
      let(:form_klass) { 'Hyrax::Forms::BatchUploadForm' }
      let(:work) { BatchUploadItem.new }
      let(:mocked_methods) { {} }

      it { is_expected.to eq %w[files metadata relationships] }
    end

    context 'when the form is a Work Form' do
      let(:form_klass) { 'Hyrax::PublicationForm' }

      it_behaves_like 'it presents the standard form tabs'
    end
  end
end
