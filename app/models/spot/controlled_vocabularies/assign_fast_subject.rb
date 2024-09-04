# frozen_string_literal: true
module Spot
  module ControlledVocabularies
    # ActiveTriples::Resource for Subject properties that uses OCLC's assignFAST API
    # to retrieve RDF URIs and labels. OCLC's FAST RDF service appears to have been
    # deprecated (experimental.worldcat.org URL has been discontinued), so this
    # retains the Resource interface but makes a call to the JSON web API to retrieve labels.
    #
    # @example
    #   uri = 'https://id.worldcat.org/fast/485998/'
    #   subject = Spot::ControlledVocabularies::AssignFastSubject.new(uri)
    #   subject.rdf_label
    #   #=> ['https://id.worldcat.org/fast/485998/']
    #   subject.fetch
    #   subject.rdf_label
    #   #=> ['Wishman, Doris, 1920-2002']
    #
    class AssignFastSubject < Base
      def fetch(*args)
        return super unless subject_is_fast?

        # clear out old labels
        RdfLabel.destroy_by(uri: rdf_subject.to_s)

        find_or_create_from_cache do |label|
          label.value = search_for_fast_id
        end
      end

      private

      # We override Qa::Authorities::AssignFast::GenericAuthority
      # to return a more informative hash from the search results.
      # We search the :type property for an 'auth' response, and
      # fall back to the first response if 'auth' isn't found for
      # for some reason.
      #
      # @see config/initializers/spot_overrides.rb
      def search_for_fast_id
        results = idroot_subauthority.search(fast_id)
        auth_result = results.find { |res| res[:type] == 'auth' } || results.first

        auth_result.fetch(:value, nil)
      end

      # 'idroot' is not included in Qa::Authorities::AssignFast's subauthorities,
      # but it allows us to search using FAST IDs, which we've been passed from
      # the form submission.
      #
      # @see config/initializers/spot_overrides.rb
      def idroot_subauthority
        Qa::Authorities::AssignFast.subauthority_for('idroot')
      end

      def fast_id
        rdf_subject_uri.path.gsub(/\/fast\//, '')
      end

      def pick_preferred_label
        return super unless subject_is_fast?
        RdfLabel.label_for(uri: rdf_subject.to_s) || rdf_subject
      end

      def subject_is_fast?
        rdf_subject_uri.host == 'id.worldcat.org' && rdf_subject_uri.path.start_with?('/fast/')
      end

      def rdf_subject_uri
        URI.parse(rdf_subject.to_s)
      end
    end
  end
end
