require 'date'

FactoryBot.define do
  factory :trustee_document do
    id { ActiveFedora::Noid::Service.new.mint }

    date_created { [FFaker::Time.date] }
    source ['Meeting of the Board of Trustees']

    title do
      date = Date.parse(date_created.first).strftime('%B %d, %Y')
      ["Lafayette College : #{source.first}, #{date}"]
    end

    sequence :start_page { |n| n + 100 }
    sequence :end_page { |n| n + 110 }

    admin_set do
      AdminSet.find(AdminSet.find_or_create_default_admin_set_id)
    end

    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED

    transient do
      file { nil }
      user { nil }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key) if evaluator.user

      # TODO: add ability to attach multiple files
      unless evaluator.file.nil?
        actor = Hyrax::Actors::FileSetActor.new(FileSet.create, evaluator.user)
        actor.create_metadata({})
        actor.create_content(Hyrax::UploadedFile.create(file: file))
        actor.attach_to_work(work)
      end
    end
  end
end
