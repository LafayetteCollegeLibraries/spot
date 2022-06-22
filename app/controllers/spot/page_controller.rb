# frozen_string_literal: true
module Spot
  class PageController < ApplicationController
    include Hyrax::Breadcrumbs

    layout 'errors'

    before_action :set_home_breadcrumb, except: [:error_404, :error_500]

    def about
      add_breadcrumb t('spot.page.about.header', name: t('hyrax.product_name')), about_path
    end

    def help
      add_breadcrumb t('spot.page.help.header', name: t('hyrax.product_name')), help_path
    end

    def terms_of_use
      add_breadcrumb t('spot.page.terms_of_use.header'), terms_of_use_path
    end

    def error_404;end
    def error_500;end

    private

    def set_home_breadcrumb
      add_breadcrumb t('hyrax.controls.home'), root_path
    end
  end
end
