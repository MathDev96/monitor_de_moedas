require "net/http"
require "json"
require "uri"

class HomeController < ApplicationController
  # Moedas que serão consultadas
  CURRENCIES = [
    { code: "USD-BRL" },
    { code: "EUR-BRL" },
    { code: "BTC-BRL" }
  ]

  def index
    @chart_data = {}

    CURRENCIES.each do |currency|
      url = URI("https://economia.awesomeapi.com.br/json/daily/#{currency[:code]}/30")
      response = Net::HTTP.get(url)
      data = JSON.parse(response)

      hash = {}
      data.each do |entry|
        date = Time.at(entry["timestamp"].to_i)
        rate = entry["high"].to_f
        hash[date] = rate
      end

      @chart_data << { name: currency[:code], data: hash }
    end
  end
end
