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

    def self.label_for(email: nil, api_key: ENV.fetch(API_ENV_KEY))
      new(api_key: api_key).label_for(email: email)
    end

    # @param [Hash] options
    # @option [String] term
    #   Termcode to retrieve instructors for (ex. '202130')
    # @option [String] api_key
    #   API key to use
    # @return [Array<Qa::LocalAuthorityEntry>]
    def self.load(term:, api_key: ENV.fetch(API_ENV_KEY))
      new(api_key: api_key).load(term: term)
    end

    # Load authority data from JSON file as a way to circumvent
    # the WDS service (which has been flaky wrt our code lately).
    #
    # @param [Hash]
    # @option [String] path
    #   Path to JSON file to load
    # @option [String] api_key
    #   API key to use (defaults to LAFAYETTE_WDS_API_KEY environment variable)
    def self.load_data(data:, api_key: ENV.fetch(API_ENV_KEY))
      new(api_key: api_key).load_from(data: data)
    end

    # @param [Hash] options
    # @option [String] api_key
    #   API key to use (defaults to LAFAYETTE_WDS_API_KEY environment variable)
    def initialize(api_key: ENV.fetch(API_ENV_KEY))
      @api_key = api_key
    end

    # @param [Hash] options
    # @option [String] term
    #   Termcode to retrieve instructors for (ex. '202130')
    # @return [Array<Qa::LocalAuthorityEntry>]
    # @todo how should we handle exceptions?
    def load(term:)
      load_from(data: instructors_for(term: term))
    end

    # Load entries from data source without invoking the WDS service
    #
    # @param [Hash] options
    # @option [Array<Hash>] data
    # @return [Array<Qa::LocalAuthorityEntry>]
    def load_from(data:)
      deactivate_entries

      data.map do |instructor|
        find_or_create_entry(from: instructor)
      end
    end

    # @param [Hash] options
    # @option [String] email
    # @return [String]
    def label_for(email:)
      stored = find_local_label_for(email: email)
      return stored unless stored.nil?

      remote = wds_service.person(email: email)
      raise(UserNotFoundError, "No user found with email address: #{email}") if remote == false

      find_or_create_entry(from: remote).label
    end

    # prevent our api_key from leaking
    #
    # @return [String]
    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end

    private

    attr_reader :api_key

    def deactivate_entries
      Qa::LocalAuthorityEntry.where(local_authority: local_authority).update(active: false)
    end

    def find_local_label_for(email:)
      qa = Qa::LocalAuthorityEntry.find_by(uri: email, local_authority: local_authority)
      return qa.label unless qa.nil?

      user = User.find_by(email: email)
      user&.authority_name
    end

    def find_or_create_entry(from:)
      user = find_or_create_user(from)

      Qa::LocalAuthorityEntry.find_or_initialize_by(local_authority: local_authority, uri: user.email).tap do |entry|
        entry.label = user.authority_name
        entry.save
      end
    end

    def find_or_create_user(params)
      User.find_or_create_by(email: params.fetch('EMAIL').downcase) do |user|
        user.given_name = params['PREFERRED_FIRST_NAME'] || params['FIRST_NAME']
        user.surname = params['LAST_NAME']
      end
    end

    def instructors_for(term:)
      wds_service.instructors(term: term)
    end

    def local_authority
      @local_authority ||= Qa::LocalAuthority.find_or_create_by(name: SUBAUTHORITY_NAME)
    end

    def wds_service
      Spot::LafayetteWdsService.new(api_key: api_key)
    end
  end
end
