# frozen_string_literal: true
class FixityCheckBatch < ApplicationRecord
  class Summary
    attr_reader :success, :failed, :failed_item_ids, :total_time

    def initialize(success:, failed:, failed_item_ids:, total_time:)
      @success = success
      @failed = failed
      @failed_item_ids = failed_item_ids
      @total_time = total_time
    end

    def to_h
      { success: success, failed: failed,
        failed_item_ids: failed_item_ids, total_time: total_time }
    end

    # Loads a Summary object from a JSON string
    #
    # @param [String] json
    # @return [FixityCheckBatch::Summary]
    def self.load(json)
      return nil if json.blank?
      parsed = JSON.parse(json).with_indifferent_access

      new(parsed)
    end

    # Turns a Summary into JSON.
    #
    # @param [Hash,FixityCheckBatch::Summary] obj
    # @return [String]
    # @raise [StandardException] raised when +obj+ is neither a Hash or Summary object
    def self.dump(obj)
      obj = obj.with_indifferent_access if obj.is_a? Hash

      case obj
      when self
        JSON.dump(obj.to_h)
      when Hash
        JSON.dump(new(obj).to_h)
      else
        raise StandardException, "Expected #{self} or Hash, got #{obj.class}"
      end
    end
  end

  has_and_belongs_to_many :checksum_audit_logs # rubocop:disable Rails/HasAndBelongsToMany
  serialize :summary, Summary

  delegate :success, :failed, :failed_item_ids, :total_time, to: :summary

  # @return [ActiveRecord::AssociationRelation]
  def failures
    checksum_audit_logs.where(passed: false)
  end

  # @return [Integer]
  def item_count
    checksum_audit_logs.count
  end
end
