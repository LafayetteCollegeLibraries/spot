# frozen_string_literal: true
#
# Tiny job wrapper that calls our HandleMintingService
# to do the heavy-lifting.
class MintHandleJob < ApplicationJob
  def perform(work)
    work = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: work) if work.is_a?(String)
    Spot::HandleService.new(work).mint
  end
end
