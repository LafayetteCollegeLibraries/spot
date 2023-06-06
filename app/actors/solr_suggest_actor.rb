# frozen_string_literal: true
class SolrSuggestActor < ::Hyrax::Actors::AbstractActor
  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def create(env)
    next_actor.create(env) && update_suggest_dictionaries
  end

  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def update(env)
    next_actor.update(env) && update_suggest_dictionaries
  end

  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def destroy(env)
    next_actor.destroy(env) && update_suggest_dictionaries
  end

  private

  # Enqueue the job to update the solr suggest dictionaries if this actor
  # isn't a part of a batch ingest
  #
  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def update_suggest_dictionaries
    Spot::UpdateSolrSuggestDictionariesJob.perform_now
  end
end
