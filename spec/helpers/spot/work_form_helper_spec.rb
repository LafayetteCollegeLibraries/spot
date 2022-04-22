# frozen_string_literal: true
RSpec.describe Spot::WorkFormHelper do
  describe '#form_tabs_for' do
    subject { helper.form_tabs_for(form: form) }

    let(:form_klass) { 'Hyrax::PublicationForm' }
    let(:form) { form_klass.constantize.new(work, Ability.new(user), nil) }
    let(:user) { FactoryBot.create(:user) }
    let(:factory_klass) { form_klass.constantize.model_class.to_s.underscore.to_sym }
    let(:work) { FactoryBot.build(factory_klass) }
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

  describe 'workflow_comment methods' do
    let(:comment) { Sipity::Comment.new(agent: sipity_agent, comment: comment_text, created_at: Time.zone.local(2022, 4, 22)) }
    let(:comment_text) { "Looks good.\r\n\r\nGreat work!" }
    let(:sipity_agent) { Sipity::Agent.new }
    let(:current_user) { FactoryBot.build(:user) }
    let(:user) { FactoryBot.build(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(current_user)
      allow(sipity_agent).to receive(:proxy_for).and_return(user)
    end

    describe '#workflow_comment_content' do
      subject { helper.workflow_comment_content(comment) }

      it { is_expected.to eq 'Looks good.<br><br>Great work!' }
    end

    describe '#workflow_comment_attribution' do
      subject { helper.workflow_comment_attribution(comment) }

      it { is_expected.to eq "#{user.display_name} (#{user.email}) commented on April 22, 2022" }

      context 'when current_user is the commenter' do
        let(:user) { current_user }

        it { is_expected.to eq 'You commented on April 22, 2022' }
      end
    end
  end
end
