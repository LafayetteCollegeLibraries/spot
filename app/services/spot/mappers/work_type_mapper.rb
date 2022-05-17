# frozen_string_literal: true
module Spot::Mappers
  # A general purpose mapper to be used for Hyrax models when the attached metadata's
  # keys match properties on the model.
  #
  # @example
  #   mapper = Spot::Mappers::WorkTypeMapper.for(:student_work)
  #   mapper.metadata = { 'title' => ['A Cool StudentWork'], 'advisor' => ['faculty_member@lafayette.edu'] }
  #   mapper.advisor # => ['faculty_member@lafayette.edu']
  #   mapper.donor # => raises NoMethodError since StudentWork doesn't implement 'donor'
  #
  # @example Mapping a field with URI values
  #   mapper = Spot::Mappers::WorkTypeMapper.for(:student_work)
  #   mapper.metadata = { 'title' => ['Presque Rien'], 'subject' => ['http://id.worldcat.org/fast/1030904'] }
  #   mapper.subject # => [#<RDF::URI URI:http://id.worldcat.org/fast/1030904>]
  #
  class WorkTypeMapper < BaseMapper
    EXCLUDED_PROPERTIES = %w[
      arkivo_checksum
      create_date
      date_uploaded
      date_modified
      has_model
      head
      modified_date
      on_behalf_of
      owner
      proxy_depositor
      state
      tail
    ].freeze

    # @param [#to_s] type
    #   'WorkClass' or :work_class String/Symbol/#to_s value used
    #   to constantize into a class
    def self.for(type)
      klass = type.to_s.camelize.constantize
      new(work_type: klass)
    end

    attr_reader :work_type

    # @param [Class] work_type
    #   Class of work type to be mapped to
    def initialize(work_type:)
      @work_type = work_type
      @properties = (@work_type&.properties&.keys || []) - EXCLUDED_PROPERTIES

      self.fields_map = @properties.map { |v| [v.to_sym, v] }.to_h
    end

    # Uses the fields_map to retrieve properties from the metadata hash,
    # where present, and converts values starting
    #
    # @param [String,Symbol] key
    # @return [Array<String,RDF::URI>,nil]
    # @see {Spot::Mappers::BaseMapper#map_field}
    def map_field(key)
      super&.map { |v| v.start_with?('http://', 'https://') ? RDF::URI(v) : v }
    end

    def representative_files
      file_key = metadata.keys.find { |k| k.to_s =~ /(representative_)?files?/i }
      return [] if file_key.nil?

      metadata.fetch(file_key, [])
    end
    alias representative_file representative_files
  end
end
