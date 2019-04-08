# frozen_string_literal: true

# A (slightly) simpler way of creating classes with some
# reasonable defaults.
module Spot
  class CollectionTypeDoesNotExistError < StandardError; end

  class CollectionFromConfig
    attr_reader :title, :metadata, :collection_type, :visibility

    # Initialize from a parsed YAML configuration file
    # (here to make our lives easier within a Rake task).
    # A hash of metadata is processed so that keys are
    # symbols and values are wrapped in arrays.
    #
    # @param config [Hash] A single parsed YAML block
    # @option 'title' [String] Title of the collection
    # @option 'metadata' [Hash] Collection metadata
    # @option 'collection_type' [String] the +machine_id+ of a Hyrax::CollectionType
    # @option 'visibility' [String] one of: 'public', 'authenticated', 'private'
    # @raise [CollectionTypeDoesNotExistError] see {#parse_collection_type}
    def self.from_yaml(config)
      new(
        title: config['title'],
        metadata: wrap_metadata(config['metadata'] || {}),
        collection_type: config['collection_type'],
        visibility: config['visibility']
      )
    end

    # @param :title [String] Title of the collection (required)
    # @param :metadata [Hash] Collection metadata attributes
    # @param :collection_type [String] the +machine_id+ of a Hyrax::CollectionType
    # @param :visibility [String] one of: 'public', 'authenticated', 'private'
    # @raise [CollectionTypeDoesNotExistError] see {#parse_collection_type}
    def initialize(title:,
                   metadata: {},
                   collection_type: default_collection_type,
                   visibility: default_visibility)
      @title = title
      @metadata = metadata
      @collection_type = parse_collection_type(collection_type)
      @visibility = parse_visibility(visibility)
    end

    # Our own homespun version of +ActiveRecord::Base.find_or_create_by_title+.
    # We'll check to see if a Collection of the same name
    # exists and return that if so. Otherwise, we'll create a new one.
    #
    # @return [Collection]
    def create
      # since ActiveFedora::Base doesn't have a '.find_or_create_by'
      # method, we'll reproduce that behavior
      existing = Collection.where(title: [title])&.first
      return existing unless existing.nil?

      collection = Collection.create! do |col|
        col.attributes = { title: [title] }.merge(metadata)
        col.collection_type = collection_type
        col.visibility = visibility
        col.apply_depositor_metadata(deposit_user&.user_key) if deposit_user
      end

      # add permissions to the collection
      Hyrax::Collections::PermissionsCreateService.create_default(
        collection: collection,
        creating_user: deposit_user
      )

      collection
    end

    private

      # Processes a raw hash from +YAML.safe_load+ to one having
      # symbolized keys and Array-ified values.
      #
      # @param [Hash]
      # @return [Hash<Symbol => Array>]
      private_class_method def self.wrap_metadata(metadata)
        metadata.each_with_object({}) do |(key, val), obj|
          # we want to get rid of whitespace that may creep in
          # as a side effect of using yaml
          obj[key.to_sym] = Array.wrap(val.strip).reject(&:blank?)
        end
      end

      # If no collection_type is provided, we'll use +user_collection+
      #
      # @return [String]
      def default_collection_type
        Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID
      end

      # @return [User]
      # @todo Use a configuration variable (or class_attribute) to set this
      def deposit_user
        @deposit_user ||= User.find_by_email('dss@lafayette.edu')
      end

      # Finds a CollectionType by a provided +machine_id+ String.
      #
      # @param value [String] A CollectionType's +machine_id+ property
      # @return [Hyrax::CollectionType]
      # @raise [CollectionTypeDoesNotExistError] if CollectionType machine_id does not exist
      def parse_collection_type(value)
        value = default_collection_type if value.blank?

        type = Hyrax::CollectionType.find_by(machine_id: value)
        raise CollectionTypeDoesNotExistError, "CollectionType #{value} does not exist" if type.nil?

        type
      end

      # Converts an easy-to-read value to its official
      # Hydra::AccessControls value. Only 'authenticated'
      # and 'public' will result in a different visibility,
      # everything else defaults to 'private'
      #
      # @param value [String] one of 'authenticated', 'public'
      # @return [String] the Hydra::AccessControls::AccessRight constant
      def parse_visibility(value)
        # safe navigating in case visibility is nil
        case value&.downcase
        when 'authenticated'
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
        when 'public'
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        else
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        end
      end
  end
end
