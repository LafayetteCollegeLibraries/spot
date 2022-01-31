# frozen_string_literal: true
module Spot
  class WorkTypeInventoryMailer < ::ApplicationMailer
    def work_type_inventory
      # generate the file
      path_to_inventory_file = Spot::WorkTypeInventoryService.call
      inventory_basename = File.basename(path_to_inventory_file)

      attachments[inventory_basename] = File.read(path_to_inventory_file)

      mail(to: 'repository@lafayette.edu',
           subject: "WorkType inventories for #{Time.zone.today.strftime('%B %-d, %Y')}")
    end
  end
end
