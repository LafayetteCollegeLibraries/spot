# frozen_string_literal: true
class SolrSuggestActor < ::Hyrax::Actors::AbstractActor
  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def create(env)
    next_actor.create(env) && update_suggest_dictionaries(env)
  end

  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def update(env)
    next_actor.update(env) && update_suggest_dictionaries(env)
  end

  # @param [Hyrax::Actors::Environment] env
  # @return [void]
  def destroy(env)
    next_actor.destroy(env) && update_suggest_dictionaries(env)
  end

  private

    # Enqueue the job to update the solr suggest dictionaries if this actor
    # isn't a part of a batch ingest
    #
    # @param [Hyrax::Actors::Environment] env
    # @return [void]
    def update_suggest_dictionaries(env)
      Spot::UpdateSolrSuggestDictionariesJob.perform_now unless part_of_batch_ingest?(env)
    end

    # @return [Symbol]
    def batch_ingest_key
      ::Spot::Importers::Base::RecordImporter::BATCH_INGEST_KEY
    end

    # Does the environment's attributes include the BATCH_INGEST_KEY?
    #
    # @param [Hyrax::Actors::Environment] env
    # @return [true, false]
    def part_of_batch_ingest?(env)
      env.attributes.include?(batch_ingest_key) && env.attributes[batch_ingest_key] == true
    end
end
