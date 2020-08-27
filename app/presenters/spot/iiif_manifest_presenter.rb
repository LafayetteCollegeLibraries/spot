# frozen_string_literal: true
module Spot
  # Our local subclassing of +Hyrax::IiifManifestPresenter+ which allows us to retain the extra
  # fiddling with manifest_metadata that we were previously doing in the publication/image presenters.
  class IiifManifestPresenter < ::Hyrax::IiifManifestPresenter
    def manifest_metadata
      metadata_fields.map do |field|
        raw_values = send(field.to_sym)
        next if raw_values.blank?

        # our controlled fields are typically a [uri, label] tuple.
        # for now, we'll only use the label of the value,
        # but this is where we would map to a Hash of URI and label
        wrapped_and_scrubbed_values = Array.wrap(raw_values).map { |v| v.is_a?(Array) ? v.last : v }.map { |v| scrub(v.to_s) }

        { 'label' => I18n.t("blacklight.search.fields.#{field}", default: field.to_s.humanize.titleize),
          'value' => wrapped_and_scrubbed_values }
      end.compact
    end
  end
end
