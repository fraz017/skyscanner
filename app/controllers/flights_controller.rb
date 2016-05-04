require "scanner"
class FlightsController < ApplicationController
  def live_prices
    @prices = Scanner.live_price(params[:flight])
  end
end
