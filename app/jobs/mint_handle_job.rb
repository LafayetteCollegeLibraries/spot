# frozen_string_literal: true
#
# Tiny job wrapper that calls our HandleMintingService
# to do the heavy-lifting.
class MintHandleJob < ApplicationJob
  def perform(work)
    Spot::HandleService.new(work).mint
  end
end
