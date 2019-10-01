# frozen_string_literal: true

# A (slightly) simpler way of creating classes with some
# reasonable defaults.
module Spot
  class CollectionTypeDoesNotExistError < StandardError; end

  class CollectionFromConfig
    attr_reader :title, :metadata, :collection_type, :visibility, :slug

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
        visibility: config['visibility'],
        slug: config['slug']
      )
    end

    # @param options [Hash]
    # @option title [String] Title of the collection (required)
    # @option metadata [Hash] Collection metadata attributes
    # @option collection_type [String] the +machine_id+ of a Hyrax::CollectionType
    # @option visibility [String] one of: 'public', 'authenticated', 'private'
    # @option slug [String] URL slug for the collection
    # @raise [CollectionTypeDoesNotExistError] see {#parse_collection_type}
    def initialize(title:, metadata: {},
                   collection_type: default_collection_type,
                   visibility: default_visibility, slug: nil)
      @title = title
      @metadata = metadata
      @collection_type = parse_collection_type(collection_type)
      @visibility = parse_visibility(visibility)
      @slug = slug
    end

    # Applies the configuration to a new (or existing) collection,
    # using the title as the unique key.
    #
    # @return [Collection]
    def create_or_update!
      collection = find_or_initialize_by_title.tap do |col|
        col.assign_attributes(attributes_for_collection)
        col.apply_depositor_metadata(deposit_user.user_key)
      end

      # need to grab this before saving, but we can't call the PermissionsCreateService
      # until after the Collection is persisted
      is_new_record = collection.new_record?

      collection.save! if collection.changed?

      create_permissions(collection) if is_new_record

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
          obj[key.to_sym] = Array.wrap(val).map(&:strip).reject(&:blank?)
        end
      end

      # @return [Hash<Symbol => *>]
      def attributes_for_collection
        {
          attributes: { title: [title] }.merge(metadata),
          collection_type: collection_type,
          visibility: visibility
        }.tap do |attr|
          if slug.present?
            attr[:attributes][:identifier] ||= []
            attr[:attributes][:identifier] += ["slug:#{slug}"]
          end
        end
      end

      # @param [Collection]
      # @return [void]
      def create_permissions(collection)
        Hyrax::Collections::PermissionsCreateService.create_default(
          collection: collection,
          creating_user: deposit_user
        )
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

      # Need to implement this behavior on our own, as ActiveFedora doesn't.
      #
      # @return [Collection]
      def find_or_initialize_by_title
        Collection.where(title: [title])&.first || Collection.new
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
