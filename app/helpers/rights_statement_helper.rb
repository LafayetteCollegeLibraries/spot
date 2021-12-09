# frozen_string_literal: true
module RightsStatementHelper
  # @param uri [String] uri of the rights statement
  # @param label [String] label for the statement
  # @return [String]
  def rights_statement_icon(uri, label = '')
    label = uri if label.blank?
    image_path = rs_icon_path_for(uri)
    link_content =
      if image_path.nil?
        %(#{label} <span class="fa fa-external-link"></span>).html_safe
      else
        image_tag(image_path, alt: label, class: 'rights-statement-icon')
      end

    link_to(link_content, uri, target: '_blank')
  end

  private

  # @param uri [String]
  # @return [String, nil]
  def rs_icon_path_for(uri)
    case uri
    when %r{^https?://creativecommons\.org/licenses/([^/]+)/}
      image_path "rights-icons/cc-#{Regexp.last_match(1)}.svg"
    when %r{^https?://creativecommons\.org/publicdomain/(mark|zero)/}
      image_path "rights-icons/pd-#{Regexp.last_match(1)}.svg"
    when %r{^https?://rightsstatements\.org/vocab/([^/]+)/}
      image_path "rights-icons/rs-#{Regexp.last_match(1).downcase}.svg"
    end
  end
end
