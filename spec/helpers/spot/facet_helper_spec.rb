# frozen_string_literal: true
RSpec.describe Spot::FacetHelper, type: :helper do
  before do
    allow(helper).to receive(:blacklight_config).and_return blacklight_config
  end

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field 'creator_ssim'
      config.add_facet_field 'subject_ssim'
      config.add_facet_field 'depositor_ssim', admin: true
      config.add_facet_field 'admin_set_ssim', admin: true
    end
  end

  describe '.general_facet_names' do
    subject { helper.general_facet_names }

    it { is_expected.to eq ['creator_ssim', 'subject_ssim'] }
  end

  describe '.render_general_facet_partials' do
    before do
      allow(helper).to receive(:render_facet_partials)
      helper.render_general_facet_partials
    end

    it 'calls render_facet_partials with the general facet names' do
      expect(helper)
        .to have_received(:render_facet_partials)
        .with(helper.general_facet_names)
    end
  end

  describe '.admin_facet_names' do
    subject { helper.admin_facet_names }

    it { is_expected.to eq ['depositor_ssim', 'admin_set_ssim'] }
  end

  describe '.render_admin_facet_partials' do
    before do
      allow(helper).to receive(:render_facet_partials)
      helper.render_admin_facet_partials
    end

    it 'calls render_facet_partials with the admin facet names' do
      expect(helper)
        .to have_received(:render_facet_partials)
        .with(helper.admin_facet_names)
    end
  end

  describe '.render_catalog_visibility_facet' do
    subject { helper.render_catalog_visibility_facet(visibility) }

    let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    it { is_expected.to eq '<span class="label label-success">Public</span>' }
  end

  describe '#admin_facets?' do
    subject { helper.admin_facets? }

    let(:user) { create(:user) }
    let(:admin_user) { create(:admin_user) }
    let(:current_user) { admin_user }

    before do
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'when current_user is not an admin' do
      let(:current_user) { user }

      it { is_expected.to be false }
    end

    context 'when no admin_facets are defined' do
      before do
        allow(helper).to receive(:admin_facet_names).and_return []
      end

      it { is_expected.to be false }
    end

    context 'when facets are in the request' do
      let(:facet) { double }

      before do
        allow(helper).to receive(:facets_from_request).and_return([facet])
      end

      context 'when any of the facets should be rendered' do
        before do
          allow(helper).to receive(:should_render_facet?).with(facet).and_return true
        end

        it { is_expected.to be true }
      end

      context 'when none of the facets should be rendered' do
        before do
          allow(helper).to receive(:should_render_facet?).with(facet).and_return false
        end

        it { is_expected.to be false }
      end
    end
  end
end
