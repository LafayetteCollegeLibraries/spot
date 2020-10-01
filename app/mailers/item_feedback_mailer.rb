# frozen_string_literal: true
class ItemFeedbackMailer < ApplicationMailer
  # @todo set as ENV value
  default to: 'malantoa@lafayette.edu'

  def feedback
    @item = params[:item]
    @user_email = params[:user][:email]
    @user_name = params[:user][:name]
    @comment = params[:comment]

    mail(from: from_address, subject: "Item Feedback Submission for #{@item.id}")
  end

  private

    # @return [String]
    def from_address
      return @user_email unless @user_name.present?

      "#{@user_name} <#{@user_email}>"
    end
end
