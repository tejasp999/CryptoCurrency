//
//  PriceVC.swift
//  CryptoTracker
//
//  Created by Teja PV on 10/25/18.
//  Copyright © 2018 Teja PV. All rights reserved.
//

import UIKit
import SwiftChart

class PriceVC: UIViewController, CoinDataDelegate {

    var chart = Chart()
    var coin : Coin?
    var priceLabel = UILabel()
    var ownedCoinLabel = UILabel()
    var worthLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let coin = coin{
            CoinData.shared.delegate = self
            edgesForExtendedLayout = []
            title = coin.shortCode
            view.backgroundColor = UIColor.white
            view.translatesAutoresizingMaskIntoConstraints = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
            chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/2)
            chart.yLabelsFormatter = {CoinData.shared.doubleToString(double: $1)}
            chart.xLabels = [30,25,20,15,10,5,0]
            chart.xLabelsFormatter = { String(Int(round(30 - $1 ))) + "d"}
            view.addSubview(chart)
            let imageView = UIImageView(frame: CGRect(x: view.frame.size.width/2.5, y: (view.frame.size.height/2) + 20, width: view.frame.size.width/4, height: view.frame.size.height/8))
            imageView.image = coin.image
            view.addSubview(imageView)
            priceLabel = UILabel(frame: CGRect(x: view.frame.size.width/2.5, y: (view.frame.size.height/2) + (view.frame.size.height/8) + 10, width: view.frame.size.width/4, height: 50))
            priceLabel.textAlignment = .center
            priceLabel.text = coin.priceAsString()
            view.addSubview(priceLabel)
            ownedCoinLabel = UILabel(frame: CGRect(x: 0, y: (view.frame.size.height/2) + (view.frame.size.height/8) + 60, width: view.frame.size.width, height: 50))
            ownedCoinLabel.textAlignment = .center
            ownedCoinLabel.text = "You own \(coin.amount) \(coin.shortCode)"
            ownedCoinLabel.font = UIFont.boldSystemFont(ofSize: 20)
            view.addSubview(ownedCoinLabel)
            worthLabel = UILabel(frame: CGRect(x: 0, y: (view.frame.size.height/2) + (view.frame.size.height/8) + 110, width: view.frame.size.width, height: 50))
            worthLabel.textAlignment = .center
            worthLabel.backgroundColor = UIColor.blue
            worthLabel.text = coin.amountAsString()
            worthLabel.font = UIFont.boldSystemFont(ofSize: 20)
            view.addSubview(worthLabel)
            coin.getHistoricalData()
        }
    }
    
    @objc func editTapped(){
        if let coin = coin{
            let alert = UIAlertController(title: "How much \(coin.shortCode) do you own?", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "0.5"
                textField.keyboardType = .decimalPad
                if self.coin?.amount != 0{
                    textField.text = String(coin.amount)
                }
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                if let text = alert.textFields![0].text{
                    if let amount = Double(text){
                        self.coin?.amount = amount
                        UserDefaults.standard.set(amount, forKey: coin.shortCode + "amount")
                        self.newPrices()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func newHistory() {
        if let coin = coin{
            let series = ChartSeries((coin.historicalData))
            series.area = true
            chart.add(series)
        }
    }
    func newPrices() {
        if let coin = coin {
            priceLabel.text = coin.priceAsString()
            ownedCoinLabel.text = "You own \(coin.amount) \(coin.shortCode)"
            worthLabel.text = coin.amountAsString()
        }
    }
    

}
