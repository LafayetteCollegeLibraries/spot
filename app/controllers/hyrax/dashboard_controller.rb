# frozen_string_literal: true
module Hyrax
  # Changing the Hyrax behavior slightly to _not_ display a dashboard
  # if a user has not been assigned to the 'depositor' role.
  #
  # NOTE: when migrating to Hyrax@3, be sure to uncomment the definition
  # of the +:sidebar_partials+ class attribute below!
  class DashboardController < ApplicationController
    include Blacklight::Base
    include Hyrax::Breadcrumbs
    with_themed_layout 'dashboard'
    before_action :authenticate_user!
    before_action :build_breadcrumbs, only: [:show]
    before_action :set_date_range

    class_attribute :create_work_presenter_class
    self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

    ##
    # @!attribute [rw] sidebar_partials
    #   @return [Hash]
    #
    # @example Add a custom partial to the tasks sidebar block
    #   Hyrax::DashboardController.sidebar_partials[:tasks] << "hyrax/dashboard/sidebar/custom_task"
    class_attribute :sidebar_partials
    self.sidebar_partials = { activity: [], configuration: [], repository_content: [], tasks: [] }

    def show
      if can? :read, :admin_dashboard
        @presenter = Hyrax::Admin::DashboardPresenter.new
        @admin_set_rows = Hyrax::AdminSetService.new(self).search_results_with_work_count(:read)
        render 'show_admin'

      # @see {Ability#depositor_abilities}
      elsif can? :read, :dashboard
        @presenter = Dashboard::UserPresenter.new(current_user, view_context, params[:since])
        @create_work_presenter = create_work_presenter_class.new(current_user)
        render 'show_user'
      else
        redirect_to root_path
      end
    end

    private

    def set_date_range
      @start_date = params[:start_date] || Time.zone.today - 1.month
      @end_date = params[:end_date] || Time.zone.today + 1.day
    end
  end
end
