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
    SUBAUTHORITY_NAME = 'lafayette_instructors'

    class UserNotFoundError < StandardError; end

    def self.label_for(email:, api_key: ENV['LAFAYETTE_WDS_API_KEY'])
      new(api_key: api_key).label_for(email: email)
    end

    # @param [Hash] options
    # @option [String] term
    #   Termcode to retrieve instructors for (ex. '202130')
    # @option [String] api_key
    #   API key to use
    # @return [Array<Qa::LocalAuthorityEntry>]
    def self.load(term:, api_key: ENV['LAFAYETTE_WDS_API_KEY'])
      new(api_key: api_key).load(term: term)
    end

    # @param [Hash] options
    # @option [String] api_key
    #   API key to use (defaults to LAFAYETTE_WDS_API_KEY environment variable)
    def initialize(api_key: ENV['LAFAYETTE_WDS_API_KEY'])
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
        auth_entry_from_user(user_from_wds_data(instructor))
      end
    end

    # @param [Hash] options
    # @option [String] email
    # @return [String]
    def label_for(email:)
      find_or_create_from_email(email).label
    end

    # prevent our api_key from leaking
    #
    # @return [String]
    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end

    private

    attr_reader :api_key

    def auth_entry_from_user(user)
      Qa::LocalAuthorityEntry.find_or_initialize_by(local_authority: local_authority, uri: user.email).tap do |entry|
        entry.label = user.authority_name
        entry.save
      end
    end

    def blank_wds_response(email)
      Rails.logger.warn("Creating empty authority label for #{email}")
      { 'LAST_NAME' => email, 'FIRST_NAME' => '', 'EMAIL' => email }
    end

    def deactivate_entries
      Qa::LocalAuthorityEntry.where(local_authority: local_authority).update(active: false)
    end

    def find_or_create_from_email(email)
      # 1. check local authority
      auth_entry = Qa::LocalAuthorityEntry.find_by(uri: email, local_authority: local_authority)
      return auth_entry if auth_entry.present?

      # 2. check local users
      local_user = User.find_by(email: email)
      return auth_entry_from_user(local_user) if local_user.present?

      # 3. query wds
      wds_data = wds_user_data_from_email(email)
      wds_user = user_from_wds_data(wds_data)
      auth_entry_from_user(wds_user)
    end

    def instructors_for(term:)
      wds_service.instructors(term: term)
    end

    def local_authority
      @local_authority ||= Qa::LocalAuthority.find_or_create_by(name: SUBAUTHORITY_NAME)
    end

    def user_from_wds_data(data)
      User.find_or_create_by(email: data.fetch('EMAIL').downcase) do |user|
        user.given_name = data['PREFERRED_FIRST_NAME'] || data['FIRST_NAME']
        user.surname = data['LAST_NAME']
      end
    end

    def wds_service
      Spot::LafayetteWdsService.new(api_key: api_key)
    end

    def wds_user_data_from_email(email)
      wds_service.person(email: email) || blank_wds_response(email)
    rescue => e
      Rails.logger.warn("WDS returned the following error: #{e.message}")
      blank_wds_response(email)
    end
  end
end
