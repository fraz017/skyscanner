class Notifier < ApplicationMailer

  default from: "SkyFare"

  def notify_user(user, object)
    @user = user
    @object = object
    mail(to: @user.email, subject: 'Reduction in prices')
  end
end
