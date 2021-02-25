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
      if discover_groups.present? && discover_groups.include?('public') && !read_groups.include?('open')
        'metadata'
      else
        super
      end
    end

    private

      # Sets discover groups to +['public']+ and read groups to +['admin']+ only
      #
      # @return [void]
      def metadata_only_visibility!
        visibility_will_change! unless visibility == 'metadata'
        set_discover_groups([Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC], [])
        set_read_groups(['admin'], read_groups)
      end
  end
end
