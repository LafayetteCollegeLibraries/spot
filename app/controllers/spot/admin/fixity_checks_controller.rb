# frozen_string_literal: true
module Spot
  module Admin
    class FixityChecksController < ApplicationController
      with_themed_layout 'dashboard'

      def show
        add_breadcrumb t('hyrax.controls.home'), root_path
        add_breadcrumb t('hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t('spot.dashboard.fixity.title'), admin_fixity_checks_path

        @error_count = ChecksumAuditLog.latest_checks.where(passed: false).count
        @errors = ChecksumAuditLog.latest_checks
                                  .where(passed: false)
                                  .page(params[:page])
                                  .per(15)
      end
    end
  end
end
