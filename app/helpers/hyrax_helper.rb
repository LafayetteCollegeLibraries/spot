# frozen_string_literal: true
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/helpers/hyrax/title_helper.rb#L18-L22
  def default_page_title
    i18n_key = "spot.#{controller_name.underscore}"
    i18n_key = "#{i18n_key}.#{action_name.downcase}" if action_name

    construct_page_title(t("#{i18n_key}.page_title", default: controller_name.titleize))
  end
end
