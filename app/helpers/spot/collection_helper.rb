# frozen_string_literal: true
module Spot
  module CollectionHelper
    def collection_banner_file_path(presenter)
      image_path(presenter.banner_file.present? ? presenter.banner_file : 'default-collection-background.jpg')
    end

    # Responsible for generating the text that preceeds a collection's
    # related_resource URLs.
    #
    # @param [Hyrax::CollectionPresenter] presenter
    # @return [String]
    def render_related_resource_language(presenter)
      return nil if presenter.related_resource.empty?

      is_multiple = presenter.related_resource.count > 1
      translation_key = "spot.collections.show.related_resource_#{is_multiple ? 'multiple' : 'single'}"

      links = presenter.related_resource.map { |url| link_to(url, url, target: '_blank').html_safe }
      t(translation_key, link_html: links.to_sentence).html_safe
    end
  end
end
