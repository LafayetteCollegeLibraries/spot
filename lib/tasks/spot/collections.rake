# frozen_string_literal: true

namespace :spot do
  namespace :collections do
    desc 'List Collection ids and titles (useful when ingesting items)'
    task list: [:environment] do
      list = Collection.all.map { |c| [c.id, c.title.first] }
      puts " ID       || TITLE"
      puts "==========||=========="
      list.each { |(id, title)| puts "#{id} || #{title}" }
    end
  end
end
