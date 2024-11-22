# frozen_string_literal: true
RSpec.describe PublicationResourceForm, valkyrization: true do
  it_behaves_like 'it supports local/standard identifiers'
  it_behaves_like 'it includes Hyrax::FormFields', schema: :core_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :base_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :publication_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :institutional_metadata

  # @todo test validation to ensure date_available is set
  describe '#date_available' do
    let(:form) { described_class.for(resource) }
    let(:resource) { PublicationResource.new(**metadata) }
    let(:metadata) { {} }
    let(:incoming_metadata) { {} }

    context 'when a value is present' do
      let(:metadata) { { date_available: ['1986-02-11'] } }

      it 'uses the existing value' do
        expect { form.validate(incoming_metadata) }
          .not_to change { form.date_available }
      end
    end

    context 'when an embargo_release_date is present' do
      let(:incoming_metadata) { { embargo_release_date: DateTime.new(2024, 11, 22) } }

      it 'uses the value' do
        expect { form.validate(incoming_metadata) }
          .to change { form.date_available }
          .from([])
          .to(['2024-11-22'])
      end
    end

    context 'when no value or embargo available' do
      it "uses today's date" do
        expect { form.validate(incoming_metadata) }
          .to change { form.date_available }
          .from([])
          .to([Time.zone.now.strftime('%Y-%m-%d')])
      end
    end
  end

  describe 'language-tagged resource fields' do
    describe "#abstract" do
      let(:field) { :abstract }
      it_behaves_like 'a language-tagged resource field'
    end

    describe "#description" do
      let(:field) { :description }
      it_behaves_like 'a language-tagged resource field'
    end

    describe "#subtitle" do
      let(:field) { :subtitle }
      it_behaves_like 'a language-tagged resource field'
    end

    describe "#title" do
      let(:field) { :title }
      it_behaves_like 'a language-tagged resource field'
    end

    describe "#title_alternative" do
      let(:field) { :title_alternative }
      it_behaves_like 'a language-tagged resource field'
    end
  end

  describe 'nested attribute fields' do
    describe '#academic_department' do
      let(:field) { :academic_department }
      it_behaves_like 'a nested attribute field'
    end

    describe '#division' do
      let(:field) { :division }
      it_behaves_like 'a nested attribute field'
    end

    describe '#language' do
      let(:field) { :language }
      it_behaves_like 'a nested attribute field'
    end

    describe '#subject' do
      let(:field) { :subject }
      it_behaves_like 'a nested attribute field'
    end
  end
end
