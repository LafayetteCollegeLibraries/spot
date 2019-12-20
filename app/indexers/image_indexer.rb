# frozen_string_literal: true
class ImageIndexer < BaseIndexer
  include IndexesSortableDate

  self.sortable_date_property = :date
end
