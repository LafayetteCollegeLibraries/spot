# frozen_string_literal: true
module Spot
  module Listeners
    # Listener replacement for SolrSuggestActor to update all of the
    # Solr suggest dictionaries after a work's metadata is updated
    # (these are used to power the autocomplete for fields like
    # :keyword and :creator).
    #
    # Add an instance of this listener to the Hyrax::Publisher in
    # the hyrax_events initializer.
    #
    # @example
    #   Hyrax.publisher.subscribe(Spot::Listeners::SolrSuggestDictionaryListener.new)
    #
    class SolrSuggestDictionariesListener
      def on_object_metadata_updated(_event)
        ::Spot::UpdateSolrSuggestDictionariesJob.perform_now
      end
    end
  end
end
