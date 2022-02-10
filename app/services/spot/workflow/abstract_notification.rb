# frozen_string_literal: true
module Spot
  module Workflow
    # Hyrax::Workflow::AbstractNotification, but with some extra helpers
    class AbstractNotification < ::Hyrax::Workflow::AbstractNotification
      private

      def advisors
        return [] unless document.respond_to?(:advisor)
        document.advisor.map { |email| User.find_by(email: email) }
      end

      def comment_html
        "\n\n<blockquote>#{comment.gsub(/\n/, '<br>')}</blockquote>\n\n"
      end

      def depositor_user
        @depositor_user ||= User.find_by(email: document.depositor)
      end

      def edit_document_path
        key = document.model_name.singular_route_key
        Rails.application.routes.url_helpers.send("edit_#{key}_path", document.id)
      end
    end
  end
end
