namespace :spot do
  namespace :rdf do
    desc 'Loads remote RDF terms locally'
    task :load, [:name, :uri] => [:environment] do |_t, args|
      abort 'Need to provide [name, uri] parameters' unless args[:name] && args[:uri]
      Spot::RDFAuthorityParser.import_rdf(args[:name], Array(args[:uri]))
    end
  end
end
