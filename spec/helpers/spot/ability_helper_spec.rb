# frozen_string_literal: true
RSpec.describe Spot::AbilityHelper, type: :helper do
  describe '#visibility_options' do
    subject { helper.visibility_options(variant) }

    let(:public_viz) { [I18n.t('hyrax.visibility.open.text'), Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC] }
    let(:authenticated_viz) { [I18n.t('hyrax.institution_name'), Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED] }
    let(:metadata_viz) { [I18n.t('hyrax.visibility.metadata.text'), 'metadata'] }
    let(:private_viz) { [I18n.t('hyrax.visibility.restricted.text'), Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE] }

    context ':restrict variant' do
      let(:variant) { :restrict }

      it { is_expected.not_to include public_viz }
      it { is_expected.to include metadata_viz }
      it { is_expected.to include authenticated_viz }
      it { is_expected.to include private_viz }
    end

    context ':loosen variant' do
      let(:variant) { :loosen }

      it { is_expected.to include public_viz }
      it { is_expected.to include metadata_viz }
      it { is_expected.to include authenticated_viz }
      it { is_expected.not_to include private_viz }
    end
  end
end
