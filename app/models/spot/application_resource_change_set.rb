class ApplicationResourceChangeSet < ::Hyrax::ChangeSet
  property :title, multiple: false, required: true
  property :resource_type, required: true
  property :rights_statement, multiple: false, required: true
end