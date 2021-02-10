# frozen_string_literal: true
module Spot
  # Mixin for WorkShowPresenters to determine if an item
  module MetadataOnlyDisplay
    # Conditions for whether to display only metadata or the files attached:
    #   - "admin" users can see files for all items
    #   - if the user can +:download+ a record (which includes those that can +:read+),
    #     we'll show the file
    #     - if the item is "authenticated" and the user is logged in, show the file
    #     - if the item is "public" and not embargoed, show the file
    #
    # Otherwise, we'll display just the metadata.
    #
    # @return [true, false]
    def metadata_only?
      @metadata_only ||= !(current_ability.admin? || current_ability.can?(:download, solr_document))
    end

    # Text content for the alert informing the user that they can not view a work's files.
    # This should probably be moved to a helper method that uses the presenter and I18n.
    #
    # @return [Strinng]
    def metadata_only_alert_text
      if embargo_release_date.present?
        "This item is under embargo until <strong>#{solr_document.embargo_release_date.strftime('%B %e, %Y')}</strong>.".html_safe
      elsif visibility == 'authenticated' && !current_ability.can?(:download, solr_document)
        "This item is restricted to members of the Lafayette College community."
      else
        "This item is unavailable to view."
      end
    end
  end
end
