# frozen_string_literal: true
module Spot
  # Helpers for mailto and page links
  module ContactHelper
    def repository_copyright_contact_mailto_link
      link_to(repository_copyright_email, "mailto:#{repository_copyright_email}")
    end

    # - Contact Nora Zimmerman, Digital Repository Librarian at ...
    # - Contact Nora Zimmerman at ...
    # - Contact our Digital Repository Librarian at ...
    # - Contact us at ....
    def repository_librarian_name_and_title
      name = I18n.t('spot.contact.repository_librarian.name', default: nil)
      title = I18n.t('spot.contact.repository_librarian.title', default: nil)

      if name && title
        "#{name}, #{title}"
      elsif name
        name
      elsif title
        "our #{title}"
      else
        "us"
      end
    end

    def repository_librarian_mailto_link
      link_to(repository_librarian_email, "mailto:#{repository_librarian_email}").html_safe
    end

    def repository_contact_mailto_link
      link_to(repository_contact_email, "mailto:#{repository_contact_email}")
    end

    def repository_contact_email
      @repository_contact_email ||= I18n.t('spot.contact.repository.email', default: department_email)
    end

    def repository_copyright_email
      @repository_copyright_email ||= I18n.t('spot.contact.copyright.email', default: department_email)
    end

    def repository_librarian_email
      @repository_librarian_email ||= I18n.t('spot.contact.repository_librarian.email', default: department_email)
    end

    def department_email
      @department_email ||= I18n.t('spot.contact.department.email')
    end
  end
end
