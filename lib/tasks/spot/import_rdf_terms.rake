namespace :spot do
  namespace :rdf do
    desc 'Loads LOC Language terms locally'
    task load_languages: [:environment] do
      reload_authorities('languages', 'http://id.loc.gov/vocabulary/iso639-1.nt')
    end

    def reload_authorities(name, source_files)
      Spot::RDFAuthorityParser.import_rdf(name, Array(source_files))
    end
  end
end
