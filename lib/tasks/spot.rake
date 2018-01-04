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

    user = User.find_by_email('malantoa@lafayette.edu')

    # save ourselves the hassle by just defining the metadata
    imported_attributes = {
      :contributor => ["Ohlin, Alix"],
      :title => ["In trouble with the Dutchman"],
      :issued => "2006",
      :publisher => ["Massachusetts Review"],
      :identifier => ["http://hdl.handle.net/10385/47"],
      :language => ["en_US"],
      :department => ["English"],
      :division => ["Humanities"],
      :organization => ["Lafayette College"],
    }
    
    visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    doc = Document.new
    doc.attributes = imported_attributes
    doc.visibility = visibility
    doc.admin_set = AdminSet.find('5999n3367') # LDR admin-set
    doc.date_uploaded = Hyrax::TimeService.time_in_utc
    doc.date_modified = Hyrax::TimeService.time_in_utc
    doc.apply_depositor_metadata(user.user_key)
    doc.save

    file = File.open('ingest/3/data/30777430134051182729313705105830045094.pdf')
    file_set = FileSet.new

    actor = Hyrax::Actors::FileSetActor.new(file_set, user)
    actor.create_metadata(visibility: visibility)
    actor.create_content(file)
    actor.attach_to_work(doc)
    actor.file_set.permissions_attributes = doc.permissions.map(&:to_hash)

    file_set.save

    Hyrax::Workflow::WorkflowFactory.create(doc, imported_attributes, user)
  end




    # Zip::File.open("ingest/3.zip") do |zip_file|
    #   zip_file.each do |entry|
    #     puts "entry: #{entry}"
    #   end
    # end
end