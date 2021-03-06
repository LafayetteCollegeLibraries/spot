# frozen_string_literal: true
module Spot
  class PageController < ApplicationController
    include Hyrax::Breadcrumbs

    def about
      add_breadcrumb t('hyrax.controls.home'), root_path
      add_breadcrumb t('spot.page.about.header', name: t('hyrax.product_name')), about_path
    end

    def help
      add_breadcrumb t('hyrax.controls.home'), root_path
      add_breadcrumb t('spot.page.help.header', name: t('hyrax.product_name')), help_path
    end

    def terms_of_use
      add_breadcrumb t('hyrax.controls.home'), root_path
      add_breadcrumb t('spot.page.terms_of_use.header'), terms_of_use_path
    end
  end
end
