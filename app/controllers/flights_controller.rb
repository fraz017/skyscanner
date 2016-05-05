require "scanner"
class FlightsController < ApplicationController
  def live_prices
    response = Scanner.live_price(params[:flight])
    cookies[:prices_url] = response[:prices_url]
    @prices = HTTParty.get(cookies[:prices_url])
  end

  def refresh
    @prices = HTTParty.get(cookies[:prices_url])
    render template: "flights/live_prices"
  end
end
