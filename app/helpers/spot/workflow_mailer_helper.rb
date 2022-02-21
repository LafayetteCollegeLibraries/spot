# frozen_string_literal: true
module Spot
  # Helper methods used within Spot::WorkflowMessageMailer
  module WorkflowMailerHelper
    def advisor_names
      @advisor_names ||= User.where(email: @document.advisor.to_a).pluck(:display_name)
    end

    def comment_html
      @comment.gsub(/\n/, '<br>').html_safe
    end

    def depositing_user
      User.find_by(email: @document.depositor)
    end

    def document_title
      @document.title.first
    end

    def document_url
      Rails.application.routes.url_helpers.send("#{route_key}_url", @document.id, host: ENV['URL_HOST'])
    end

    def edit_document_url
      Rails.application.routes.url_helpers.send("edit_#{route_key}_url", @document.id, host: ENV['URL_HOST'])
    end

    def route_key
      @document.model_name.singular_route_key
    end

    def submission_has_comment?
      @comment.present?
    end

    # The title of the Workflow Actions form widget. Hardcoded in Hyrax < 3 to "Review and Approval"
    # but uses I18n.t beyond that.
    #
    # @todo update after Hyrax v3 upgrade
    def workflow_actions_title
      "Review and Approval"
      # I18n.t('hyrax.base.workflow_actions.title')
    end
  end
end
