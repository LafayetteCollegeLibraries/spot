# frozen_string_literal: true
#
# Indexes + stores standard and local identifiers, rather than delegating
# the task to the presenter. This allows us to access these values from
# the solr document and thus outside of the Hyrax scope, if need be.
#
# @example
#   module Hyrax
#     class ThingIndexer < WorkIndexer
#       include IndexesIdentifiers
#     end
#   end
#
module IndexesIdentifiers
  # @return [Hash<String => *>]
  def generate_solr_document
    super.tap do |doc|
      doc['identifier_standard_ssim'] = mapped_identifiers.select(&:standard?).map(&:to_s)
      doc['identifier_local_ssim'] = mapped_identifiers.select(&:local?).map(&:to_s)
    end
  end

  private

    # @return [Array<Spot::Identifier>]
    def mapped_identifiers
      @mapped_identifiers ||= object.identifier.map { |id| Spot::Identifier.from_string(id) }
    end
end
