# frozen_string_literal: true
module Spot
  module WorkFormHelper
    # This provides an array of additional partials to display under the work form's Visibility
    # widget. We're going to use it to allow users to submit workflow actions from within the
    # form, rather than requiring the work form to be submitted before the workflow actions form
    # also needs to be submitted. This workflow still remains, users just have the ability to
    # do so from the edit screen.
    #
    # Since workflows aren't initiated until after the work is created, we'll only need to
    # pass this partial (found at app/views/hyrax/base/_form_progress_workflow_actions.html.erb)
    # when the work has been persisted.
    #
    # @param [Hash] options
    # @option [Hyrax::Forms::WorkForm] form
    # @return [Array<String>]
    # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/views/hyrax/base/_form_progress.html.erb#L30-L32
    def form_progress_sections_for(form:)
      return [] unless form.model.persisted?

      ['workflow_actions']
    end

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
      # `super` handles BatchUploadForm's special case, and since we aren't
      # concerned with representative_media in that case, return the results
      fields = super
      return fields if form.instance_of?(Hyrax::Forms::BatchUploadForm)

      persisted = form.model.persisted?
      return student_work_form_tabs(persisted: persisted) if form.instance_of?(Hyrax::StudentWorkForm) && !current_user.admin?

      # if the model has been persisted, load the "media" partial and the new "comments" panel
      # to display any workflow comments that may exist.
      #
      # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/views/hyrax/base/_form_media.html.erb
      # @todo maybe take this check out of the partial?
      fields += ['media', 'comments'] if persisted

      fields
    end

    # Adds text to the footer of the comment's panel: "FirstName LastName commented on April 22, 2022"
    # or "You commented on April 22, 2022" if the current_user made the comment.
    #
    # @param [Sipity::Comment] comment
    # @return [String]
    def workflow_comment_attribution(comment)
      commenter = comment.agent.proxy_for
      commenter_display = current_user == commenter ? 'You' : "#{commenter.display_name} (#{commenter.email})"
      "#{commenter_display} commented on #{comment.created_at.strftime('%B %-d, %Y')}"
    end

    # Formats the workflow comment content to display line breaks properly.
    #
    # @param [Sipity::Comment] comment
    # @return [String]
    def workflow_comment_content(comment)
      comment.comment.gsub(/\r?\n/, '<br>').html_safe
    end

    # Form fields specifically for student users (removes "relationship" tab)
    #
    # @param [Hash] options
    # @option [true, false] persisted
    # @return [Array<String>]
    # @api private
    def student_work_form_tabs(persisted: false)
      persisted ? %w[metadata files comments] : %w[metadata files]
    end
  end
end
