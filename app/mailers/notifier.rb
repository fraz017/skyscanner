class Notifier < ApplicationMailer

  default from: "SkyFare"
  layout 'mailer'
  def notify_user(user, object)
    @user = user
    @cheap = object
    mail(to: @user.email, subject: 'Cheapest Flights Prices Summary')
  end

  def notify_user_hotels(user, object, currency)
    @user = user
    @hotels = object
    @currency = currency
    mail(to: @user.email, subject: 'Cheapest Hotel Prices Summary')
  end
end
