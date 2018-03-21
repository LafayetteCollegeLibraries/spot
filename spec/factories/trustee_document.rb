require 'date'

FactoryBot.define do
  factory :trustee_document do
    date_created { FFaker::Time.date }
    source ['Meeting of the Board of Trustees']
    title do
      date = Date.parse(date_created).strftime('%B %d, %Y')
      ["Lafayette College : #{source}, #{date}"]
    end

    sequence :start_page { |n| n + 100 }
    sequence :end_page { |n| n + 110 }
  end
end
