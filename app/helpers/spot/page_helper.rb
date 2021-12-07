# frozen_string_literal: true
module Spot
  module PageHelper
    def repository_librarian_mailto_link
      link_to(repository_librarian_email, "mailto:#{repository_librarian_email}").html_safe
    end

    # @todo put this into a config file
    def repository_librarian_email
      'zimmerno@lafayette.edu'
    end
  end
end
