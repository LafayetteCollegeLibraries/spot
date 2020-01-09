# frozen_string_literal: true
class SolrSuggestActor < ::Hyrax::Actors::AbstractActor
  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def create(env)
    set_batch_flag(env)
    next_actor.create(env) && update_suggest_dictionaries(env)
  end

  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def update(env)
    @part_of_batch = false
    next_actor.update(env) && update_suggest_dictionaries(env)
  end

  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def destroy(env)
    @part_of_batch = false
    next_actor.destroy(env) && update_suggest_dictionaries(env)
  end

  private

    # Enqueue the job to update the solr suggest dictionaries if this actor
    # isn't a part of a batch ingest
    #
    # @param [Hyrax::Actors::Environment] env
    # @return [void]
    def update_suggest_dictionaries(env)
      Spot::UpdateSolrSuggestDictionariesJob.perform_now unless part_of_batch?
    end

    # @return [Symbol]
    def batch_ingest_key
      ::Spot::Importers::Base::RecordImporter::BATCH_INGEST_KEY
    end

    # @return [true, false]
    def part_of_batch?
      !!@part_of_batch
    end

    # Sets an instance variable flag if the batch_ingest_key is part of
    # the environment's attributes.
    #
    # @param [Hyrax::Actors::Environment] env
    # @return [void]
    def set_batch_flag(env)
      @part_of_batch = !!env.attributes.delete(batch_ingest_key)
    end
end
