# frozen_string_literal: true
module Spot
  # mixin to enable a 'metadata' visibility, intended to be interpreted as:
  #   - the work's metadata is visible
  #   - the work's files are only visible to admins
  module MetadataOnlyVisibility
    extend ActiveSupport::Concern

    # @return [void]
    # @see https://github.com/samvera/hydra-head/blob/v11.0.0/hydra-access-controls/app/models/concerns/hydra/access_controls/visibility.rb#L5-L18
    def visibility=(value)
      return super unless value == 'metadata'

      # setup our discover/read groups
      metadata_only_visibility!

      # need to set this manually, as +super+ would be doing that work
      @visibility = value
    end

    # @return [String]
    # @see https://github.com/samvera/hydra-head/blob/v11.0.0/hydra-access-controls/app/models/concerns/hydra/access_controls/visibility.rb#L20-L28
    def visibility
      if read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      elsif read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      elsif discover_groups.include?(Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC)
        'metadata'
      else
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      end
    end

    private

    def set_visibility_discover_groups
      set_discover_groups([Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC], discover_groups)
    end

    # Sets discover groups to +['public']+ and read groups to +['admin']+ only
    #
    # @return [void]
    def metadata_only_visibility!
      visibility_will_change! unless visibility == 'metadata'
      set_visibility_discover_groups
      set_read_groups([Ability.admin_group_name], read_groups)
    end

    # Be sure to remove the ['public'] from discover_groups if we're making this work private
    #
    # @return [void]
    def private_visibility!
      super
      set_discover_groups([], discover_groups)
    end

    # Ensure unauthenticated users are able to view metadata of authenticated items.
    def registered_visibility!
      super
      set_visibility_discover_groups
    end
  end
end
