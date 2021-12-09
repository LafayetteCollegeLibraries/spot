# frozen_string_literal: true
module Spot
  # Service for loading Instructors from Lafayette's Web Data Services API into
  # a QuestioningAuthority table-based LocalAuthority. Separating this from the
  # {Spot::LafayetteWdsService} in the event that we need to swap out querying
  # the API for something else (maybe a regular CSV dump).
  #
  # @example Loading instructors for the Winter 2021 term
  #   Spot::LafayetteInstructorsAuthorityService.load(term: '202130', api_key: ENV.fetch('LAFAYETTE_WDS_API_KEY'))
  #   # => [#<Qa::LocalAuthorityEntry id: 1, local_authority_id: 1...>...]
  class LafayetteInstructorsAuthorityService
    API_ENV_KEY = 'LAFAYETTE_WDS_API_KEY'
    SUBAUTHORITY_NAME = 'lafayette_instructors'

    class UserNotFoundError < StandardError; end

    def self.label_for(lnumber:, api_key: ENV.fetch(API_ENV_KEY))
      new(api_key: api_key).label_for(lnumber: lnumber)
    end

    # @params [Hash] options
    # @option [String] term
    #   Termcode to retrieve instructors for (ex. '202130')
    # @option [String] api_key
    #   API key to use
    # @return [Array<Qa::LocalAuthorityEntry>]
    def self.load(term:, api_key: ENV.fetch(API_ENV_KEY))
      new(api_key: api_key).load(term: term)
    end

    # @params [Hash] options
    # @option [String] api_key
    #   API key to use (defaults to LAFAYETTE_WDS_API_KEY environment variable)
    def initialize(api_key: ENV.fetch(API_ENV_KEY))
      @api_key = api_key
    end

    # @params [Hash] options
    # @option [String] term
    #   Termcode to retrieve instructors for (ex. '202130')
    # @return [Array<Qa::LocalAuthorityEntry>]
    # @todo how should we handle exceptions?
    def load(term:)
      instructors_for(term: term).map do |instructor|
        find_or_create_entry(label: instructor_label(instructor), value: instructor_id(instructor))
      end
    end

    def label_for(lnumber:)
      stored = Qa::LocalAuthorityEntry.find_by(uri: lnumber, local_authority: local_authority)
      return stored.label unless stored.nil?

      remote = wds_service.person(lnumber: lnumber)
      raise(UserNotFoundError, "No user found with L-number: #{lnumber}") if remote == false

      find_or_create_entry(label: instructor_label(remote), value: instructor_id(remote)).label
    end

    # prevent our api_key from leaking
    #
    # @return [String]
    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end

  private

    attr_reader :api_key

    def find_or_create_entry(label:, value:)
      entry = Qa::LocalAuthorityEntry.find_or_initialize_by(local_authority: local_authority, uri: value)
      entry.label = label
      entry.save
      entry
    end

    def instructors_for(term:)
      wds_service.instructors(term: term)
    end

    def instructor_id(instructor)
      instructor['LNUMBER']
    end

    def instructor_label(instructor)
      "#{instructor['LAST_NAME']}, #{instructor['FIRST_NAME']}"
    end

    def local_authority
      @local_authority ||= Qa::LocalAuthority.find_or_create_by(name: SUBAUTHORITY_NAME)
    end

    def wds_service
      Spot::LafayetteWdsService.new(api_key: api_key)
    end
  end
end
