# frozen_string_literal: true
RSpec.describe Spot::StudentWorkSearchBuilder do
  describe '#only_active_works' do
    subject(:active_work_query) { builder.only_active_works(params) }

    let(:builder) { described_class.new(scope).with(blacklight_params) }
    let(:params) { {} }
    let(:scope) { OpenStruct.new(current_ability: current_ability) }
    let(:blacklight_params) { { id: 'abc123def' } }
    let(:current_ability) { Ability.new(current_user) }
    let(:depositor) { FactoryBot.build(:user) }
    let(:advisor) { FactoryBot.build(:user) }
    let(:solr_document) { SolrDocument.new(solr_parameters) }
    let(:solr_parameters) { _solr_params }
    let(:_solr_params) do
      {
        'depositor_ssim' => [depositor.user_key],
        'title_tesim' => ['A Fabulous Thesis'],
        'advisor_ssim' => [advisor.user_key],
        'suppressed_bsi' => true
      }
    end

    before do
      allow(SolrDocument)
        .to receive(:find)
        .with(blacklight_params[:id])
        .and_return(solr_document)

      allow(Hyrax::Workflow::PermissionQuery)
        .to receive(:scope_permitted_workflow_actions_available_for_current_state)
        .and_return([])

      # @todo this is added as a part of Blacklight::AccessControls, which is deprecated.
      #       in the future, while upgrading to hyrax v3, this will have to be removed in
      #       favor of assigning the ability via `builder#with_ability(ability)`
      builder.current_ability = current_ability
    end

    shared_examples 'it adds the hide-suppressed parameter' do
      it do
        active_work_query
        expect(params.fetch(:fq, [])).to eq ['-suppressed_bsi:true']
      end
    end

    shared_examples 'it does not add the hide-suppressed parameter' do
      it do
        active_work_query
        expect(params.fetch(:fq, [])).to eq []
      end
    end

    context 'with a logged-in user' do
      let(:current_user) { FactoryBot.build(:user) }

      it_behaves_like 'it adds the hide-suppressed parameter'
    end

    context 'with an anonymous user' do
      let(:current_user) { nil }

      it_behaves_like 'it adds the hide-suppressed parameter'
    end

    context 'when current_user is depositor' do
      let(:current_user) { depositor }

      it_behaves_like 'it does not add the hide-suppressed parameter'
    end

    context 'when current_user is an advisor' do
      let(:current_user) { advisor }

      it_behaves_like 'it does not add the hide-suppressed parameter'
    end
  end
end
