# frozen_string_literal: true
#
# Common metadata fields to test
#
#   it_behaves_like 'it has base metadata fields'
#   it_behaves_like 'it has core metadata fields'
RSpec.shared_examples 'it has base metadata fields' do
  subject(:resource) { described_class.new }

  it 'has bibliographic_citations' do
    expect { resource.bibliographic_citation = ['Work of art. Author', 'Another citation'] }
      .to change { resource.bibliographic_citation }
      .to contain_exactly('Work of art. Author', 'Another citation')
  end

  it 'has contributors' do
    expect { resource.contributor = ['contributor'] }
      .to change { resource.contributor }
      .to contain_exactly('contributor')
  end

  it 'has creators' do
    expect { resource.creator = ['A. Creator', 'another'] }
      .to change { resource.creator }
      .to contain_exactly('A. Creator', 'another')
  end

  it 'has descriptions' do
    expect { resource.description = ['the work'] }
      .to change { resource.description }
      .to contain_exactly('the work')
  end

  it 'has identifiers' do
    expect { resource.identifier = ['local:abc123', 'ldr:000000'] }
      .to change { resource.identifier.map(&:to_s) }
      .to contain_exactly('local:abc123', 'ldr:000000')
  end

  it 'has keywords' do
    expect { resource.keyword = ['one', 'two'] }
      .to change { resource.keyword }
      .to contain_exactly('one', 'two')
  end

  it 'has languages' do
    expect { resource.language = ['en', 'fr'] }
      .to change { resource.language }
      .to contain_exactly('en', 'fr')
  end

  it 'wraps locations in Spot::ControlledVocabulries::GeonamesLocation classes' do
    expect { resource.location = ['http://sws.geonames.org/5188140/'] }
      .to change { resource.location }
      .to contain_exactly(Spot::ControlledVocabularies::GeonamesLocation.new('http://sws.geonames.org/5188140/'))
  end

  it 'has notes' do
    expect { resource.note = ['note 1', 'note 2'] }
      .to change { resource.note }
      .to contain_exactly('note 1', 'note 2')
  end

  it 'has physical_mediums' do
    expect { resource.physical_medium = ['cd'] }
      .to change { resource.physical_medium }
      .to contain_exactly('cd')
  end

  it 'has publishers' do
    expect { resource.publisher = ['McGuffin'] }
      .to change { resource.publisher }
      .to contain_exactly('McGuffin')
  end

  it 'has related_resources' do
    expect { resource.related_resource = ['https://ldr.lafayette.edu'] }
      .to change { resource.related_resource }
      .to contain_exactly('https://ldr.lafayette.edu')
  end

  it 'has resource_types' do
    expect { resource.resource_type = ['Article', 'Other'] }
      .to change { resource.resource_type }
      .to contain_exactly('Article', 'Other')
  end

  it 'has rights_holders' do
    expect { resource.rights_holder = ['T. Owner'] }
      .to change { resource.rights_holder }
      .to contain_exactly('T. Owner')
  end

  it 'has rights_statements' do
    expect { resource.rights_statement = ['http://creativecommons.org/publicdomain/mark/1.0/'] }
      .to change { resource.rights_statement }
      .to contain_exactly('http://creativecommons.org/publicdomain/mark/1.0/')
  end

  it 'has sources' do
    expect { resource.source = ['Lafayette College'] }
      .to change { resource.source }
      .to contain_exactly('Lafayette College')
  end

  it 'has source_identifiers' do
    expect { resource.source_identifier = ['ldr:import:1'] }
      .to change { resource.source_identifier }
      .to contain_exactly('ldr:import:1')
  end

  it 'has subjects' do
    expect { resource.subject = ['http://id.worldcat.org/fast/1061714'] }
      .to change { resource.subject }
      .to contain_exactly(Spot::ControlledVocabularies::AssignFastSubject.new('http://id.worldcat.org/fast/1061714'))
  end

  it 'has subtitles' do
    expect { resource.subtitle = ['A great work'] }
      .to change { resource.subtitle }
      .to contain_exactly('A great work')
  end

  it 'has title_alternatives' do
    expect { resource.title_alternative = ['Aka One', 'Aka Two'] }
      .to change { resource.title_alternative }
      .to contain_exactly('Aka One', 'Aka Two')
  end
end

RSpec.shared_examples 'it has core metadata fields' do
  subject(:resource) { described_class.new }
  let(:date) { Time.zone.today }

  it 'has titles' do
    expect { resource.title = ['Work title'] }
      .to change { resource.title }
      .to eq ['Work title']
  end

  it 'has a date_modified' do
    expect { resource.date_modified = date }
      .to change { resource.date_modified }
      .to eq date
  end

  it 'has a date_uploaded' do
    expect { resource.date_uploaded = date }
      .to change { resource.date_uploaded }
      .to eq date
  end

  it 'has a depositor' do
    expect { resource.depositor = 'repository@lafayette.edu' }
      .to change { resource.depositor }
      .to eq 'repository@lafayette.edu'
  end
end

RSpec.shared_examples 'it has institutional metadata fields' do
  subject(:resource) { described_class.new }

  it 'has academic_departments' do
    expect { resource.academic_department = ['English', 'Library'] }
      .to change { resource.academic_department }
      .to contain_exactly 'English', 'Library'
  end

  it 'has divisions' do
    expect { resource.division = ['Sciences'] }
      .to change { resource.division }
      .to contain_exactly 'Sciences'
  end

  it 'has a organization' do
    expect { resource.organization = ['Lafayette College'] }
      .to change { resource.organization }
      .to contain_exactly 'Lafayette College'
  end
end
