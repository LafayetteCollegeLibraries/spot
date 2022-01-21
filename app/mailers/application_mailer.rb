# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: 'dss@lafayette.edu'

  layout 'mailer'
end
