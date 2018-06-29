describe Publication do
  subject(:pub) { described_class.new }

  multiple_properties = %i[
    title
    subtitle
    title_alternative
    publisher
    source
    resource_type
    language
    abstract
    description
    identifier
    bibliographic_citation
    date_issued
    date_available
    creator
    contributor
    editor
    academic_department
    division
    organization
    related_resource
    keyword
    subject
    license
    rights_statement
  ]

  multiple_properties.each do |key|
    describe "##{key}" do
      subject { pub.send(key) }

      it_behaves_like 'a read and writable multiple property'
    end
  end
end
