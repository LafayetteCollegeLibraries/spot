# frozen_string_literal: true
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  # We currently don't offer translations beyond those offered in Hyrax, so we'll default
  # to English for now. This will hide a translation dropdown in the site's header.
  #
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/views/_user_util_links.html.erb
  # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/helpers/hyrax/hyrax_helper_behavior.rb#L31-L43
  def available_translations
    { 'en' => 'English' }
  end
  
  # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/helpers/hyrax/title_helper.rb#L18-L22
  def default_page_title
    i18n_key = "spot.#{controller_name.underscore}"
    i18n_key = "#{i18n_key}.#{action_name.downcase}" if action_name

    construct_page_title(t("#{i18n_key}.page_title", default: controller_name.titleize))
  end
end
