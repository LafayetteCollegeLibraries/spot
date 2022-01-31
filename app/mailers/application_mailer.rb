# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: 'repository@lafayette.edu'

  layout 'mailer'
end
