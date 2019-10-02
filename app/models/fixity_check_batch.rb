# frozen_string_literal: true
class FixityCheckBatch < ApplicationRecord
  class Summary < Struct.new(:success, :failed, :failed_item_ids, :total_time)
    # Loads a Summary object from a JSON string
    #
    # @param [String] json
    # @return [FixityCheckBatch::Summary]
    def self.load(json)
      return nil if json.blank?
      parsed = JSON.parse(json)

      new(parsed['success'], parsed['failed'], parsed['failed_item_ids'], parsed['total_time'])
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
        JSON.dump(success: obj.success,
                  failed: obj.failed,
                  failed_item_ids: obj.failed_item_ids,
                  total_time: obj.total_time)
      when Hash
        JSON.dump(success: obj[:success],
                  failed: obj[:failed],
                  failed_item_ids: obj[:failed_item_ids],
                  total_time: obj[:total_time])
      else
        raise StandardException, "Expected #{self} or Hash, got #{obj.class}"
      end
    end
  end

  has_and_belongs_to_many :checksum_audit_logs
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
