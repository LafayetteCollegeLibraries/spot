# frozen_string_literal: true
#
# The root of our mappers. Uses the Darlingtonia::HashMapper
# pattern, but rewrites essentially all of it. A child class
# needs to provide values to a +fields_map+, which works as
# a mapping from WorkClass methods to their associated keys
# within the metadata. If doing any sort of data-cleanup with
# a method, those WorkClass methods will also need to be
# added to the {#fields} array.
#
# @example An example mapper + how it's used
#   class ExcitedMapper < Spot::Mappers::BaseMapper
#     self.fields_map = {
#       description: 'dc:description',
#       subject: 'dc:subject'
#     }
#
#     def fields
#       super + [:title]
#     end
#
#     def title
#       metadata['dc:title'].map { |title| title + '!!!' }
#     end
#   end
#
#   # This comes from a Parser
#   metadata = {
#     'dc:title' => ['A good work'],
#     'dc.description' => ['Some words about it'],
#     'dc.subject' => ['Good stuff']
#   }
#
#   input_record = Darlingtonia::InputRecord.from(metadata: metadata,
#                                                mapper: ExcitedMapper.new)
#
#   work = Work.new(input_record.attributes)
#   work.title # => ['A good work!!!']
#   work.description # => ['Some words about it']
#   work.subject # => ['Good stuff']
#
# @todo Add collection/admin_set handling at this level? If not where?
module Spot::Mappers
  class BaseMapper < ::Darlingtonia::MetadataMapper
    class_attribute :fields_map, :default_visibility

    self.fields_map = {}
    self.default_visibility = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

    # Fields related to ActiveFedora::Base properties that will be set
    # on new works. This returns an array of symbols and is called from
    # within Darlingtonia::InputRecord#attributes.
    #
    # @return [Array<Symbol>]
    def fields
      fields_map.keys + [:visibility]
    end

    # @param [String, Symbol] name The field name
    # @return [any]
    def map_field(name)
      field_name = fields_map[name.to_sym]
      return nil unless field_name

      metadata[field_name]
    end

    # Copied from Darlingtonia::HashMapper. Ensures that
    # metadata added is a Hash.
    #
    # @param [#to_h] data
    # @return [Hash]
    def metadata=(data)
      @metadata = data.to_h
    end

    # @return [Array<String>] paths to files of works to be attached
    def representative_files
      metadata['representative_files']
    end
    alias representative_file representative_files

    # @return [String]
    def visibility
      return metadata['visibility'] if metadata.include?('visibility')
      default_visibility
    end
  end
end
