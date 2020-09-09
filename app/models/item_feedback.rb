# frozen_string_literal: true
class ItemFeedback
  include ActiveModel::Model

  attr_accessor :item, :user, :comment
end
