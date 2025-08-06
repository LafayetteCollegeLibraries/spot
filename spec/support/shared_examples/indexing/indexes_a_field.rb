# frozen_string_literal: true
RSpec.shared_examples 'it indexes' do |field, opts|
  suffixes = opts[:to_suffixes]

  raise 'Define a :solr_document variable with let()' unless defined?(:solr_document)
  raise 'Pass a field to the "it indexes" shared_example' unless field
  raise 'Pass an array to :to_suffixes or an array of keys to :to' unless suffixes || opts[:to]

  to_fields = opts[:to] || []

  if suffixes.present?
    to_fields += suffixes.map do |suffix|
      "#{field}_#{suffix.starts_with?('_') ? suffix[1..-1] : suffix}"
    end
  end

  to_fields.each do |solr_field|
    it "#{field} to #{solr_field}" do
      if solr_field[-1] == 'm'
        expect(solr_document[solr_field]).to eq(resource.send(field).map(&:to_s))
      else
        expect(solr_document[solr_field]).to eq(resource.send(field).to_s)
      end
    end
  end
end
