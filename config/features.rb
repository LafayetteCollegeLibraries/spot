# frozen_string_literal: true
#
# Add features that can be toggled within +/admin/features+
Flipflop.configure do
  feature :show_senior_honors_thesis_block,
          default: false,
          description: 'Display block on homepage for students to easily access the StudentWork form'
end
