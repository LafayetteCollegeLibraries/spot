# frozen_string_literal: true
#
# When using the Questioning Authority service with the Geonames API,
# users are shown labels that are a combination of multiple fields
# ('name', 'adminName1', and 'countryName') that give a more precise
# picture than what is provided by the RDF data. It's true that we
# could provide this stitching on our own, but some fields (namely,
# 'adminName1') are actually other resources that would require
# another round-trip to parse values. Since we're assuming the API
# data is being pulled from the same source as the RDF data, it seems
# Okay to store the API label value.
module Spot::ControlledVocabularies
  class Location < Base
    # Now that we're caching label values, this is not called unless
    # the resource's label matches the RDF subject. As part of the
    # preferred_label check, we call {#pick_preferred_label} which,
    # in this case, does the label fetching for us, so it's assumed
    # this method is likely to not get called indirectly. In the event
    # that it does, we'll log some info + return a symbol.
    #
    # @return [Symbol]
    def fetch(*)
      Rails.logger.info "Skipping fetch of <#{rdf_subject}> in favor of Geonames API"
      :skipped_use_geonames_api
    end

    private

    def pick_preferred_label
      RdfLabel.first_or_create(uri: rdf_subject.to_s) do |label|
        label.value = authority_class.label.call(fetch_geonames_data)
      end.value
    end

    def fetch_geonames_data
      Rails.logger.info "Fetching Geonames API data for #{geonames_id}"
      authority_class.new.find(geonames_id)
    end

    def geonames_id
      URI.parse(rdf_subject.to_s).path.gsub(/\//, '')
    end

    def authority_class
      Qa::Authorities::Geonames
    end
  end
end
