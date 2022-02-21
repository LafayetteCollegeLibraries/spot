# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: 'Lafayette Digital Repository <repository@lafayette.edu>'

  layout 'mailer'
end
