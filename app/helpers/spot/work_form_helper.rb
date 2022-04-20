# frozen_string_literal: true
module Spot
  module WorkFormHelper
    # Determines the tabs to render on a work's create/edit form. Partials for the
    # tab bodies are located in `app/views/hyrax/<work_type || 'base'>/_form_<tab>.html.erb`;
    # locales for the tab names are found at `hyrax.works.form.tab.<tab>`.
    #
    # Our overrides handle some edge cases:
    #   - StudentWorkForms should only display "Metadata" and "Add Files" tabs to non-admin users
    #   - Forms should have a "Representative Media" tab added that deals with thumbnails and objects
    #     to render in a work's viewer (previously found in the Metadata form). The intention is to
    #     build this out into more of a visual widget.
    #   - Hyrax::WorkFormHelper#form_tabs_for has special handling for Hyrax::Forms::BatchUploadForm
    #     and we aren't adding the media tab there, so exit early.
    #
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/helpers/hyrax/work_form_helper.rb#L5-L27
    def form_tabs_for(form:)
      return student_work_form_tabs_for(form: form) if form.instance_of?(Hyrax::StudentWorkForm) && !current_user.admin?

      # `super` handles BatchUploadForm's special case, and since we aren't
      # concerned with representative_media in that case, return the results
      fields = super
      return fields if form.instance_of?(Hyrax::Forms::BatchUploadForm)

      # if the model has been persisted, load the 'media' partial (if the object has members)
      # and load the new "comments" panel to display any workflow comments that may exist.
      #
      # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/views/hyrax/base/_form_media.html.erb
      # @todo maybe take this check out of the partial?
      if form.model.persisted?
        fields << 'media' if form.model.member_ids.present?
        fields << 'comments'
      end

      fields
    end

    def workflow_comment_attribution(comment)
      commenter = comment.agent.proxy_for
      commenter_display = current_user == commenter ? 'You' : "#{commenter.display_name} (#{commenter.email})"
      "#{commenter_display} commented on #{comment.created_at.strftime('%B %-d, %Y')}"
    end

    def workflow_comment_content(comment)
      comment.comment.gsub(/\r?\n/, '<br>').html_safe
    end

    # @api private
    def student_work_form_tabs_for(form:)
      %w[metadata files].tap do |fields|
        fields << 'comments' if form.model.persisted?
      end
    end
  end
end
