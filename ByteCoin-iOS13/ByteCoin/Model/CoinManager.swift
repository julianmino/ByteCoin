//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation
protocol CoinManagerDelegate {
    func didUpdatePrice(model: PriceModel, currency: String)
    func didFailwithError(error: Error)
}
struct CoinManager {
    //Delegate must be of type 'var'
    var delegate: CoinManagerDelegate?
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "482F15E9-86C5-4CD6-ABC3-A224EFE9C6F4"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailwithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let priceModel = parseJSON(priceData: safeData) {
                        self.delegate?.didUpdatePrice(model: priceModel, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(priceData:Data) -> PriceModel? {
        
        do {
            let decodedData = try JSONDecoder().decode(PriceModel.self, from: priceData)
            let rate = decodedData.rate
            let priceModel = PriceModel(rate: rate)
            return priceModel
        } catch {
            delegate?.didFailwithError(error: error)
            return nil
        }
    }
}
