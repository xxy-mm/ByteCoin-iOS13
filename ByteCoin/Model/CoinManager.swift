//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func coinPriceDidUpdate(price: Double)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "1999CFB2-A874-4DD9-B4B2-868B2DF4F641"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let url = URL(string: "\(baseURL)/\(currency)")
        guard let url = url else { return }
        performFetch(with: url)
    }
    
    func performFetch(with url: URL) {
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-CoinAPI-Key")
        let task = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            guard error == nil else {
                self.handleClientError(error)
                return
            }
            guard let response = urlResponse as? HTTPURLResponse
                    , (200...299) .contains(response.statusCode) else {
                self.handleServerError(error)
                return
            }
            guard let data = data else { return }
            
            do {
                let parsedData = try JSONDecoder().decode(CoinRate.self, from: data)
                delegate?.coinPriceDidUpdate(price: parsedData.rate)
            } catch {
                print("json parse failed: ", error)
            }
        }
        
        task.resume()
    }
    
    func handleServerError(_ error: Sendable) {
        print("server error: ", error)
    }
    
    func handleClientError(_ error: Sendable) {
        print("client error: ", error)
    }
    
    func handleJSONParseError(_ error: Sendable) {
        print("JSON parse error: ", error)
    }
    
}

struct CoinRate: Decodable {
    var rate: Double
}
