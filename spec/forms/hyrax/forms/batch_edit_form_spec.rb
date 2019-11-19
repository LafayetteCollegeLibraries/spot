# frozen_string_literal: true
#
# Copied directly from Hyrax @ d0539f3. See {Hyrax::Forms::BatchEditForm}
# for the why (tl;dr it's because we're not using +date_created+)
#
# rubocop:disable RSpec/ExampleLength
RSpec.describe Hyrax::Forms::BatchEditForm do
  let(:model) { Publication.new }
  let(:work1) do
    create(:publication,
           title: ['title 1'],
           keyword: ['abc'],
           creator: ['Wilma'],
           language: ['en'],
           contributor: ['contributor1'],
           description: ['description1'],
           note: ['a note'],
           license: ['license1'],
           subject: ['subject1'],
           identifier: ['id1'],
           location: ['location1'],
           related_resource: ['related_resource1'],
           resource_type: ['Article'],
           publisher: [])
  end

  # TODO: update this when we add another work type. This is supposed
  #       to prove that the BulkEditForm can handle works of different
  #       model types:
  #
  #       > Using a different work type in order to show that the form supports
  #       > batches containing multiple types of works
  let(:work2) do
    create(:publication,
           title: ['title 2'],
           keyword: ['123'],
           creator: ['Fred'],
           publisher: ['Rand McNally'],
           language: ['en'],
           resource_type: ['Article'],
           contributor: ['contributor2'],
           description: ['description2'],
           note: ['a note'],
           license: ['license2'],
           subject: ['subject2'],
           identifier: ['id2'],
           location: ['location2'],
           related_resource: ['related_resource2'])
  end

  let(:batch) { [work1.id, work2.id] }
  let(:form) { described_class.new(model, ability, batch) }
  let(:ability) { Ability.new(user) }
  let(:user) { build(:user, display_name: 'Jill Z. User') }

  describe "#terms" do
    subject { form.terms }

    it do
      is_expected.to eq [:creator,
                         :contributor,
                         :description,
                         :note,
                         :keyword,
                         :resource_type,
                         :license,
                         :publisher,
                         :subject,
                         :language,
                         :identifier,
                         :location,
                         :related_resource]
    end
  end

  describe "#model" do
    it "combines the models in the batch" do
      expect(form.model.creator).to match_array ['Wilma', 'Fred']
      expect(form.model.contributor).to match_array ['contributor1', 'contributor2']
      expect(form.model.description).to match_array ['description1', 'description2']
      expect(form.model.keyword).to match_array ['abc', '123']
      expect(form.model.resource_type).to match_array ['Article']
      expect(form.model.license).to match_array ['license1', 'license2']
      expect(form.model.publisher).to match_array ['Rand McNally']
      expect(form.model.subject).to match_array ['subject1', 'subject2']
      expect(form.model.language).to match_array ['en']
      expect(form.model.identifier).to match_array ['id1', 'id2', "noid:#{work1.id}", "noid:#{work2.id}"]
      expect(form.model.location).to match_array ['location1', 'location2']
      expect(form.model.related_resource).to match_array ['related_resource1', 'related_resource2']
    end
  end

  describe ".build_permitted_params" do
    subject { described_class.build_permitted_params }

    it do
      is_expected.to eq [{ creator: [] },
                         { contributor: [] },
                         { description: [] },
                         { note: [] },
                         { keyword: [] },
                         { resource_type: [] },
                         { license: [] },
                         { publisher: [] },
                         { subject: [] },
                         { language: [] },
                         { identifier: [] },
                         { location: [] },
                         { related_resource: [] },
                         { permissions_attributes: [:type, :name, :access, :id, :_destroy] },
                         :on_behalf_of,
                         :version,
                         :add_works_to_collection,
                         :visibility_during_embargo,
                         :embargo_release_date,
                         :visibility_after_embargo,
                         :visibility_during_lease,
                         :lease_expiration_date,
                         :visibility_after_lease,
                         :visibility,
                         { location_attributes: [:id, :_destroy] }]
    end
  end
end
# rubocop:enable RSpec/ExampleLength
