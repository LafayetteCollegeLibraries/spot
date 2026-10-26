# frozen_string_literal: true
module Spot
  # Service to attach any .vtt filesets available to a given video file set.
  #
  # @usage
  #   Spot::TranscriptAttachmentService.new(file_set_id: file_set_id).attach_transcripts
  #
  class TranscriptAttachmentService
    # @option [FileSet] file_set
    def initialize(file_set_id:)
      @file_set_id = file_set_id
    end

    def attach_transcripts
      file_set = Hyrax.query_service.find_by(id: @file_set_id)
      parent = Hyrax.query_service.find_parents(resource: file_set)
      return if parent.blank?
      parent = parent[0];
      transcripts = available_transcripts(parent: parent)
      return if transcripts.blank?
      transcript_ids = []
      for t in transcripts do
        transcript_ids.push(t.id)
      end
      file_set.transcript_ids = transcript_ids
      Valkyrie.config.metadata_adapter.persister.save(resource: file_set)
    end

    def available_transcripts(parent:)
         member_ids = Hyrax.custom_queries.find_child_file_set_ids(resource: parent)
         Hyrax::SolrQueryService.new
                                # Cast Valkyrie::IDs to strings
                                .with_ids(ids: member_ids.map(&:to_s).to_a)
                                .solr_documents(
                                  # Using "has_model_ssim:*FileSet" in fq will return both FileSet
                                  # and Hyrax::FileSet documents. In test mode, Koppie and Sirenia 
                                  # index file sets with has_model_ssim:Hyrax::FileSet. 
                                  # But in dev mode, they index file sets with 
                                  # has_model_ssim:FileSet instead. This query covers both cases.
                                  fq: [mime_type_filter_query.to_s, "has_model_ssim:*FileSet"],
                                  fl: "id,title_tesim",
                                  rows: 1000
                                )
    end

    def mime_type_filter_query
      valid_mime_types.map { |type| "mime_type_ssi:\"#{type}\"" }.join(" OR ")
    end

    # According to IIIF, .srt and .ttml are also acceptable but may
    # not be supported by viewers. Clover and Ramp are confirmed to work
    # with .vtt. (https://iiif.io/api/cookbook/recipe/0219-using-caption-file/).
    # When Hyrax supports Ramp, we may want to add "text/plain" (.srt) to this list.
    def valid_mime_types
      ["text/vtt"]
    end
  end
end
