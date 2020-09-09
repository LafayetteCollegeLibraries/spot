# frozen_string_literal: true
class ItemFeedbackController < ApplicationController
  def submit
    respond_to do |format|
      format.js { render js: 'console.log("ok!")' }
    end
  end
end
