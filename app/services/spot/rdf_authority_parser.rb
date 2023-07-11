# frozen_string_literal: true

# We're extending the Qa::Services::RDFAuthorityParser to check for
# labels with a preferred language tag. Currently, the parser will
# create a +Qa::LocalAuthorityEntry+ item for the first object that
# uses the predicate and will fail quietly for any others which
# follow. This stores the preferred_language tag as a class_attribute
# which can be modified with subclasses.
#
# @example
#
#   class FrenchRDFAuthorityParser < Spot::RDFAuthorityParser
#     self.preferred_language = :fr
#   end
#
#   FrenchRDFAuthorityParser.load_rdf('languages_fr', ['http://id.loc.gov/vocabulary/iso639-1.nt'])
#
module Spot
  class RDFAuthorityParser < ::Qa::Services::RDFAuthorityParser
    class_attribute :preferred_language
    self.preferred_language = :en

    class << self
      private

      # Overriding Qa::Services::RDFAuthorityParser to prefer a language tag.
      # If a statement makes it through our checks, it's passed to Qa to create
      # a +Qa::LocalAuthorityEntry+ object.
      #
      # @param [RDF::Statement] statement
      # @param [String] predicate
      # @param [Qa::Authorities::Local]
      # @return [Qa::LocalAuthorityEntry]
      def parse_statement(statement, predicate, authority)
        return unless statement.predicate == predicate
        return unless object_has_preferred_language?(statement.object)

        super
      end

      # @param [RDF::Term] object
      # @return [true, false]
      def object_has_preferred_language?(object)
        return false unless object.has_language?
        object.language == preferred_language
      end
    end
  end
end
