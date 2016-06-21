class Notifier < ApplicationMailer

  default from: "SkyFare"

  def notify_user(user, object)
    @user = user
    @object = object
    mail(to: @user.email, subject: 'Reduction in prices')
  end

  def notify_user_hotels(user, object, results)
    @user = user
    @object = object
    @results = results
    mail(to: @user.email, subject: 'Reduction in prices')
  end
end
