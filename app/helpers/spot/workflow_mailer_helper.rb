# frozen_string_literal: true
module Spot
  module WorkflowMailerHelper
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
  end
end
