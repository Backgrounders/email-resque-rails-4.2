class SendEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    UserMailer.welcome_email(user).deliver
  end
end
