# frozen_string_literal: true
#
# Concern to allow us to pass around RDF values within jobs and have
# them be applied to work objects as +RDF::Literal+s. For this to work
# properly, you'll have to make sure this syncs up with the Form object
# for the corresponding work model.
#
# @example
#   # app/models/work_type.rb
#   class WorkType < ActiveFedora::Base
#     property :title, predicate: ::RDF::Vocab::DC.title, multiple: false
#     property :description, predicate: ::RDF::Vocab::DC.description
#   end
#
#   # app/forms/hyrax/work_type_form.rb
#   module Hyrax
#     class WorkTypeForm < Hyrax::Forms::WorkForm
#       include ::LanguageTaggedFormFields
#       transforms_language_tags_for :title, :description
#     end
#   end
#
#   # app/actors/work_type_actor.rb
#   class WorkTypeActor < Hyrax::Actors::BaseActor
#     include ::DeserializesRdfLiterals
#   end
#
# This mixin calls the singleton method +.language_tagged_fields+, which
# is defined by {LanguageTaggedForm.transforms_language_tags_for}, to
# know what fields to transform -- otherwise we'd have to loop through
# _all_ of the fields and that seemed like more overhead.
#
# Note that this is required because the actor stack followed by a form
# submission differs from the one followed by a command-line ingest task.
# Also note that Rails edge (> 5.2, == 6?) adds the ability to define
# serializers for jobs, which would make this convoluted mess unnecessary.
module DeserializesRdfLiterals
  # We want our deserialization to happen _before_ the other jobs in the
  # work actor, as we're changing the +env.curation_concern+ and +env.attributes+.
  #
  # @param env [Hyrax::Actors::Environment]
  # @return [void]
  def create(env)
    deserialize_rdf_literals!(env)
    super
  end

  # We want our deserialization to happen _before_ the other jobs in the
  # work actor, as we're changing the +env.curation_concern+ and +env.attributes+.
  #
  # @param env [Hyrax::Actors::Environment]
  # @return [void]
  def update(env)
    deserialize_rdf_literals!(env)
    super
  end

private

  # Sets the tagged fields of +env.attributes+ with transformed
  # literal values unless that field is empty
  #
  # @param env [Hyrax::Actors::Environment]
  # @return [void]
  def deserialize_rdf_literals!(env)
    tagged_fields.each do |field|
      env.attributes[field] = value_for(field, env) if env.attributes[field]
    end
  end

  # Fetches the value for +field+. handles whether or not to return
  # an array or single object based on whether or not the +env.attributes[field]+
  # is an array or not.
  #
  # @param field [String,Symbol] the attributes field to fetch
  # @param env [Hyrax::Actors::Environment]
  # @return [RDF::Literal,Array<RDF::Literal>]
  def value_for(field, env)
    raw = env.attributes.delete(field)
    raw.is_a?(Array) ? raw.map { |val| deserialize(val) } : deserialize(raw)
  end

  # @return [RDF::Literal]
  def deserialize(value)
    serializer.deserialize(value) || value
  end

  # @return [RdfLiteralSerializer]
  def serializer
    @serializer ||= RdfLiteralSerializer.new
  end

  # Fetches contents of the +language_tagged_fields+ singleton method defined
  # by {LanguageTaggedForm.transforms_language_tags_for}. in the event that
  # the class method was never called to define the fields, we fall back to
  # an empty array
  #
  # @return [Array<Symbol>]
  def tagged_fields
    work_form.language_tagged_fields
  rescue NoMethodError
    []
  end

  # Does the work of +Hyrax::WorkFormService.form_class+ but via self vs a passed-through
  # work object
  #
  # @return [Hyrax::Forms::WorkForm]
  def work_form
    @work_form ||= begin
      klass = self.class.name.split('::').last.gsub(/Actor$/, '')
      Hyrax.const_get("#{klass}Form")
    end
  end
end
