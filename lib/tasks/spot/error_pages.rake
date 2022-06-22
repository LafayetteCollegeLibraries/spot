# frozen_string_literal: true
namespace :spot do
  namespace :error_pages do
    # generate static error pages using our layout
    # see: https://ryanfb.github.io/etc/2021/09/19/generating_static_error_pages_with_rails.html
    task generate: :environment do
      # unless Rails.env.production?
      #   puts 'Skipping static page generation outside production'
      #   next
      # end

      Rails.application.config.action_controller.perform_caching = false
      url_host = ENV.fetch('URL_HOST').gsub(/^https?:\/\//, '')

      class ErrorRendererController < ApplicationController
        def current_search_parameters
          {}
        end
        helper_method :current_search_parameters

        def search_form_action
          main_app.search_catalog_path
        end
        helper_method :search_form_action

        def search_state
          Struct.new(:params_for_search).new({})
        end
        helper_method :search_state
      end

      %w[404 500].each do |code|
        outpath = Rails.root.join('public', "#{code}.html")
        renderer = ErrorRendererController.renderer.new(http_host: ENV['URL_HOST'].gsub(/^https?:\/\//, ''), https: true)
        html = renderer.render(template: "spot/page/error_#{code}", layout: 'layouts/errors')

        if html.present?
          File.delete(outpath) if File.exist?(outpath)
          File.open(outpath, 'w') do |f|
            f.write(html)
          end
        else
          puts "Error generating error #{code} page"
        end
      end
    end
  end
end
