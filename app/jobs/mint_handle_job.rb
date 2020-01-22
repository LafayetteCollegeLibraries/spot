# frozen_string_literal: true
#
# Tiny job wrapper that calls our HandleMintingService
# to do the heavy-lifting.
class MintHandleJob
  def perform(work)
    HandleService.new(work).mint
  end
end
