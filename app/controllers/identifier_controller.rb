# frozen_string_literal: true

# Controller used to redirect to a document via an attached identifier.
# We're merging different URL schemes, and this should help in maintaining
# that old URLs map to new ones.
#
# To add handling for a route, you'll need to add a route to the
# +config/routes.rb+ which will define the route to expect, and
# add a method to this controller. The {#search_and_redirect_with_prefix}
# method is available to do most of the heavy-lifting for you.
#
# @example
#   # config/routes.rb
#   get '/isbn/*id', to: 'identifier#isbn'
#
#   # app/controllers/identifier_controller.rb
#   class IdentifierController < ApplicationController
#     def isbn
#       search_and_redirect_with_prefix(Spot::Identifier::ISBN)
#     end
#   end
#
# @todo what happens if there are multiple responses?
class IdentifierController < ApplicationController
  include Hydra::Catalog

  # redirecting route for items with a Handle identifier.
  def handle
    search_and_redirect_with_prefix(Spot::Identifier::HANDLE)
  end

  private

  # Searches for an item based on an identifier attached to the document.
  # Expected to be called from within a method that handles a route.
  # The +key+ option allows the params key to be something other than +:id+.
  # Displays a 404 (via raised +Blacklight::Exceptions::RecordNotFound+
  # that is handled with +Hydra::Catalog+) if no item is found.
  #
  # @param prefix [String]
  # @option key [Symbol] Optional parameter key to use for lookup
  #   (defaults to :id)
  def search_and_redirect_with_prefix(prefix, key: :id)
    query = query_for_identifier(Spot::Identifier.new(prefix, params[key]))
    result, _documents = repository.search(query)

    raise Blacklight::Exceptions::RecordNotFound if result.response['numFound'].zero?

    document = result.response['docs'].first
    controller = document['has_model_ssim'].first.downcase.pluralize

    redirect_to controller: "hyrax/#{controller}",
                action: 'show',
                id: document['id']
  end

  # @return [String]
  def identifier_solr_field
    'identifier_ssim'
  end

  # @param id [Spot::Identifier, #to_s] the identifier (with prefix)
  # @return [Hash<Symbol => String>]
  def query_for_identifier(id)
    { q: "{!terms f=#{identifier_solr_field}}#{id.to_s}" }
  end
end
