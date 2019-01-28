# frozen_string_literal: true
module DeserializesRdfLiterals
  extend ActiveSupport::Concern

  def create(env)
    deserialize_rdf_literals!(env)
    super
  end

  def update(env)
    deserialize_rdf_literals!(env)
    super
  end

  private

    def deserialize_rdf_literals!(env)
      tagged_fields.each do |field|
        env.curation_concern[field] = value_for(field, env)
      end
    end

    def value_for(field, env)
      if env.attributes[field].is_a? Array
        env.attributes[field].map { |val| deserialize(val) }
      else
        deserialize(env.attributes[field])
      end
    end

    def deserialize(value)
      serializer.deserialize(value) || value
    end

    def serializer
      @serializer ||= RdfLiteralSerializer.new
    end

    def tagged_fields
      work_form.language_tagged_fields
    rescue NoMethodError
      []
    end

    def work_form
      @work_form ||= begin
        klass = self.class.name.split('::').last.gsub(/Actor$/, '')
        Hyrax.const_get("#{klass}Form")
      end
    end
end
