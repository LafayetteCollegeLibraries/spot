# frozen_string_literal: true
class ItemFeedbackController < ApplicationController
  def submit
    user_params = {
      email: feedback_params[:email],
      name: feedback_params[:name]
    }

    item = SolrDocument.find(feedback_params[:item_id])
    ItemFeedbackMailer.with(item: item, comment: feedback_params[:comment], user: user_params).feedback.deliver_later

    respond_to { |format| format.js }
  end

  private

    def feedback_params
      params.require(:item_feedback).permit(:email, :comment, :item_id)
    end
end
