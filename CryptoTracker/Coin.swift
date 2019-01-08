//
//  Coin.swift
//  CryptoTracker
//
//  Created by Teja PV on 10/25/18.
//  Copyright © 2018 Teja PV. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol CoinDataDelegate : class{
    @objc optional func newPrices()
    @objc optional func newHistory()
}


class CoinData{
    static let shared = CoinData()
    weak var delegate : CoinDataDelegate?
    var coins = [Coin]()
    private init() {
        let shortCodes = ["BTC","ETH","LTC"]
        for shortCode in shortCodes{
            let coin = Coin(shortCode: shortCode)
            coins.append(coin)
            
        }
    }
    
    func html() -> String{
        var html = "<h1>My crypto report</h1>"
        html += "<h2>Net worth : \(netWorthAsString())</h2>"
        html += "<ul>"
        for coin in coins{
            if coin.amount != 0.0{
                html += "<li>\(coin.shortCode) - I have \(coin.amount) - Valued at \(doubleToString(double: coin.amount * coin.price))"
            }
        }
        html += "</ul"
        return ""
    }
    
    func netWorthAsString()-> String{
        var netWorth = 0.0
        for coin in coins{
            netWorth += coin.amount * coin.price
        }
        
        return doubleToString(double: netWorth)
    }
    
    func getPrices(){
        var shortCodeList = ""
        for coin in coins{
            shortCodeList += coin.shortCode
            if coin.shortCode != coins.last?.shortCode{
                shortCodeList += ","
            }
        }
        Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(shortCodeList)&tsyms=USD").responseJSON { (response) in
            if let json = response.result.value as? [String: Any]{
                for coin in self.coins{
                    if let coinJSON = json[coin.shortCode] as? [String:Double]{
                        if let price = coinJSON["USD"]{
                            coin.price = price
                            UserDefaults.standard.set(price, forKey: coin.shortCode)
                        }
                    }
                }
                self.delegate?.newPrices!()
            }
        }
    }
    
    func doubleToString(double : Double) -> String{
        //print("The double value os",double)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        if let formatPrice = formatter.string(from: NSNumber(floatLiteral: double)){
            return formatPrice
        }else {
            return "ERROR"
        }
    }
}


class Coin{
    var shortCode = ""
    var image = UIImage()
    var price = 0.0
    var amount = 0.0
    var historicalData = [Double]()
    init(shortCode : String) {
        self.shortCode = shortCode
        if let image = UIImage(named: shortCode.lowercased()){
            self.image = image
        }
        self.price = UserDefaults.standard.double(forKey: shortCode)
        self.amount = UserDefaults.standard.double(forKey: shortCode + "amount")
        if let history = UserDefaults.standard.array(forKey: shortCode + "History") as? [Double]{
            self.historicalData = history
        }
    }
    
    func getHistoricalData(){
        Alamofire.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(shortCode)&tsym=USD&limit=30").responseJSON { (response) in
            if let json = response.result.value as? [String: Any]{
                if let pricesJSON = json["Data"] as? [[String:Double]]{
                    self.historicalData = []
                    for price in pricesJSON{
                        if let closePrice = price["close"]{
                            self.historicalData.append(closePrice)
                        }
                    }
                    CoinData.shared.delegate?.newHistory!()
                    UserDefaults.standard.set(self.historicalData, forKey: self.shortCode + "History")
                }
            }
        }
    }
    
    func priceAsString()-> String{
        if price == 0.0{
            return "loading"
        }
        return CoinData.shared.doubleToString(double: price)
    }
    
    func amountAsString() -> String{
        return CoinData.shared.doubleToString(double: amount * price)
    }
}
