# frozen_string_literal: true

# Borrowed pretty much wholesale from curationexperts/mahonia:
# https://github.com/curationexperts/mahonia/blob/89b036c/spec/factories/hyrax_uploaded_files.rb

FactoryBot.define do
  factory :uploaded_pdf, class: Hyrax::UploadedFile do
    user
    file File.open('spec/fixtures/document.pdf')
  end

  factory :uploaded_image, class: Hyrax::UploadedFile do
    user
    file File.open('spec/fixtures/image.png')
  end
end
