# frozen_string_literal: true
class ItemFeedbackController < ApplicationController
  def submit
    respond_to { |format| format.js }
  end
end
