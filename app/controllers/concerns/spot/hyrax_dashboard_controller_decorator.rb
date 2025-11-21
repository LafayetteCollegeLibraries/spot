# frozen_string_literal: true
module Spot
  # Changing the Hyrax behavior slightly to only display a dashboard
  # if a user has been assigned to the 'depositor' role.
  #
  # @see config/initializers/spot_overrides.rb
  # @see https://github.com/samvera/hyrax/blob/hyrax-v5.2.0/app/controllers/hyrax/dashboard_controller.rb
  module HyraxDashboardControllerDecorator
    extend ActiveSupport::Concern

    prepended do
      class_attribute :create_work_presenter_class, default: Hyrax::SelectTypeListPresenter

      sidebar_partials[:activity] << 'hyrax/dashboard/sidebar/fixity_checks'
    end

    def show
      if can? :read, :admin_dashboard
        @presenter = Hyrax::Admin::DashboardPresenter.new
        @admin_set_rows = Hyrax::AdminSetService.new(self).search_results_with_work_count(:read)
        render 'show_admin'

      # @see {Ability#depositor_abilities}
      elsif can? :read, :dashboard
        @presenter = Hyrax::Dashboard::UserPresenter.new(current_user, view_context, params[:since])
        @create_work_presenter = create_work_presenter_class.new(current_user)
        render 'show_user'
      else
        redirect_to root_path
      end
    end
  end
end
