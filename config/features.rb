# frozen_string_literal: true
#
# Add features that can be toggled within +/admin/features+

Flipflop.configure do
  feature :search_result_contextual_match,
          default: false,
          description: 'Show search query in the context of its match on catalog results'
end
