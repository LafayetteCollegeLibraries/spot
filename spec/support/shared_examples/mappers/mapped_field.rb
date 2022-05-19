# frozen_string_literal: true
#
# Helper to test mapper fields in the +fields_map+ attribute.
#
# @example with a single field
#   describe '#title' do
#     subject { mapper.title }
#
#     let(:field) { 'dc:title' }
#
#     it_behaves_like 'a mapped field'
#   end
#
# @example with multiple fields
#   describe '#keyword' do
#     subject { mapper.keyword }
#
#     let(:fields) { ['keyword', 'another_field'] }
#
#     it_behaves_like 'a mapped field'
#   end
#
RSpec.shared_examples 'a mapped field' do
  if method_defined?(:fields)
    # This is kind of unsightly, but what I'm trying to accomplish is
    # create a metadata Hash using the `:fields` array as keys and
    # a somewhat unique value (if we used the same )
    # - create a metadata object with the +:fields+ as keys,
    # - populate each key in the metadata object with a somewhat unique value
    # - ensure that these values are mapped back to the subject of the block
    #
    # resulting in a Hash that, given `fields = [:subject, :title, :contributor]` would look like
    # `{ subject: ['a'], title: ['b'], contributor: ['c'] }`
    let(:metadata) do
      raw_values = %w[a b c d e f g h]
      Array.wrap(fields).each_with_index.each_with_object({}) do |(field, idx), obj|
        value_index = idx % raw_values.size
        obj[field] ||= []
        obj[field] += [raw_values[value_index]]
        obj
      end
    end
    let(:value) { metadata.values.flatten.uniq }
  elsif method_defined?(:field)
    let(:value) { ['some value'] }
    let(:metadata) { { field => value } }
  else
    raise '"a mapped field" shared_example expects a `let(:field)` or `let(:fields)` block'
  end

  it { is_expected.to eq value }
end
