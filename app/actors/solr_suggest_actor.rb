# frozen_string_literal: true
class SolrSuggestActor < ::Hyrax::Actors::AbstractActor
  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def create(env)
    extract_batch_flag(env)
    next_actor.create(env) && update_suggest_dictionaries
  end

  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def update(env)
    extract_batch_flag(env)
    next_actor.update(env) && update_suggest_dictionaries
  end

  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def destroy(env)
    extract_batch_flag(env)
    next_actor.destroy(env) && update_suggest_dictionaries
  end

  private

  # Enqueue the job to update the solr suggest dictionaries if this actor
  # isn't a part of a batch ingest
  #
  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def update_suggest_dictionaries
    Spot::UpdateSolrSuggestDictionariesJob.perform_now unless part_of_batch_ingest?
  end

  # @return [true, false]
  def part_of_batch_ingest?
    @part_of_batch == true
  end

  # Sets an instance variable flag if the batch_ingest_key is part of
  # the environment's attributes.
  #
  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def extract_batch_flag(env)
    @part_of_batch = env.attributes.delete(:__batch_ingest__)
  end
end
