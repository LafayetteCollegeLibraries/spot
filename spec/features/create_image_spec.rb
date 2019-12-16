# frozen_string_literal: true

RSpec.feature 'Create an Image', :clean, :js do
  before do
    # Only enqueue the ingest job, not charactarization.
    # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.image') }
  let(:app_name) { I18n.t('hyrax.product_name') }

  context 'a logged in admin user' do
    let(:user) { create(:admin_user) }
    let(:attrs) { attributes_for(:image) }

    skip 'can fill out and submit a new Image' do
    end
  end
end
