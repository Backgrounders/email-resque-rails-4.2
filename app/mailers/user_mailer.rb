class UserMailer < ActionMailer::Base
  default to: 'sunnymittal2003@gmail.com'

  def welcome_email(user)
    @user = user
    mail(from: @user.email, subject: 'Hi! Open this email...')
  end
end
