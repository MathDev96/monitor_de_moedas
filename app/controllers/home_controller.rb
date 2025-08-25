require "net/http"
require "json"
require "uri"

class HomeController < ApplicationController
  CURRENCIES = [
    { code: "USD-BRL" },
    { code: "EUR-BRL" },
    { code: "BTC-BRL" }
  ]

  def index
    @chart_data = []

    CURRENCIES.each do |currency|
      url = URI("https://economia.awesomeapi.com.br/json/daily/#{currency[:code]}/30")
      response = Net::HTTP.get(url)
      data = JSON.parse(response)

      # Dados reais
      hash = {}
      data.each do |entry|
        date = Time.at(entry["timestamp"].to_i).strftime("%d/%m")
        rate = entry["high"].to_f
        hash[date] = rate
      end

      # 🔹 Média móvel 5 dias
      values = hash.values
      dates = hash.keys
      ma5 = []
      values.each_with_index do |v, i|
        if i >= 4
          avg = values[i-4..i].sum / 5.0
          ma5 << [dates[i], avg.round(2)]
        end
      end

      # 🔹 Previsão linear para 7 dias
      slope = (values.last - values.first) / (values.size - 1)
      predicted = (1..7).map { |i|
        [(Date.strptime(dates.last, "%d/%m") + i).strftime("%d/%m"), (values.last + slope*i).round(2)]
      }

      # Adiciona ao chart_data
      @chart_data << { name: currency[:code], data: hash }               # Valores reais
      @chart_data << { name: "#{currency[:code]} MA5", data: ma5 }       # Média móvel
      @chart_data << { name: "#{currency[:code]} Prev", data: predicted } # Previsão
    end
  end
end
