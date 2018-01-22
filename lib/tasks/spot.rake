# bin/rails spot:ingest

namespace :spot do
  # TODO: create separate ingest tasks for each type/collection
  task :ingest => :environment do
    # here's what we should do:
    # 
    # 1. look for an `ingest` directory at `Rails.root`
    # 2. get a listing of everything in that directory (assume BagIt files)
    # 3. for each zip file in directory
    #   3a. check Bag integrity
    #   3b. `doc = Document.new`
    #   3c. read metadata from data/<hash>.csv into `doc`
    #   3d. attach file (data/<hash>.pdf) to `doc`
    #   3e. save `doc`

    tmp_directory = 'tmp/ingest'

    DIRECTORY_NAME = Rails.root.join('ingest')
    TMP_DIRECTORY = Rails.root.join('tmp', 'ingest')
    SKIP_ENTRIES = %w{. .. .keep .DS_Store}
    ADMIN_SET = AdminSet.where(title: 'Lafayette Digital Repository').first

    user = User.find_by_email('malantoa@lafayette.edu')
    paths = {}

    Dir.mkdir(TMP_DIRECTORY) unless Dir.exist?(TMP_DIRECTORY)

    Dir.entries(DIRECTORY_NAME).each do |listing|
      next if SKIP_ENTRIES.include?(listing)

      file_path = DIRECTORY_NAME.join(listing)
      
      puts "ingesting #{listing}"

      Zip::File.open(file_path) do |zip_file|
        file = zip_file.glob('data/*.pdf')
        metadata = zip_file.glob('data/*.csv')

        if file.count > 1
          puts "> uh-oh! contains more than one pdf!"
          next
        end

        if metadata.count > 1
          puts "> uh-oh! contains more than one csv!"
          next
        end

        if file.first.nil?
          puts "> no pdfs found, skipping"
          next
        end

        file = file.first
        metadata = metadata.first

        paths[:file] = TMP_DIRECTORY.join(File.basename(file.name))
        paths[:metadata] = TMP_DIRECTORY.join(File.basename(metadata.name))

        file.extract(paths[:file])
        metadata.extract(paths[:metadata])
      end

      raw_metadata = CSV.read(paths[:metadata])
      attributes = {}

      raw_metadata.each do |record|
        predicate, object = record[0..1]
        doc_attributes = Document.properties.values.select { |val| val.predicate.to_s == predicate }.map { |val| val }

        doc_attributes.each do |attribute|
          if attribute.multiple?
            attributes[attribute.term.to_sym] = object.split(';')
          else
            attributes[attribute.term.to_sym] = object.split(';').first
          end
        end
      end
    
      visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      doc = Document.new
      doc.attributes = attributes
      doc.visibility = visibility
      doc.admin_set = ADMIN_SET
      doc.date_uploaded = Hyrax::TimeService.time_in_utc
      doc.date_modified = Hyrax::TimeService.time_in_utc
      doc.apply_depositor_metadata(user.user_key)
      doc.save

      file = File.open(paths[:file])
      file_set = FileSet.new

      actor = Hyrax::Actors::FileSetActor.new(file_set, user)
      actor.create_metadata(visibility: visibility)
      actor.create_content(file)
      actor.attach_to_work(doc)
      actor.file_set.permissions_attributes = doc.permissions.map(&:to_hash)

      file_set.save

      Hyrax::Workflow::WorkflowFactory.create(doc, attributes, user)
    end

    # paths.each_value { |path| File.unlink(path) }
  end
end