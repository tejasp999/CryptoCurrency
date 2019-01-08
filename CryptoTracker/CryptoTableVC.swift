//
//  CryptoTableVC.swift
//  CryptoTracker
//
//  Created by Teja PV on 10/25/18.
//  Copyright © 2018 Teja PV. All rights reserved.
//

import UIKit
import LocalAuthentication

private let headerheight : CGFloat = 100
private let networthheight : CGFloat = 45

class CryptoTableVC: UITableViewController, CoinDataDelegate {

    var amountLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        CoinData.shared.getPrices()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(reportCreation))
        CoinData.shared.delegate = self
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            updateSecureButton()
        }
    }
    
    @objc func reportCreation(){
        let formatter = UIMarkupTextPrintFormatter(markupText: CoinData.shared.html())
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.2)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        let pdfdata = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfdata, .zero, nil)
        for i in 0..<render.numberOfPages{
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        let shareVC = UIActivityViewController(activityItems: [pdfdata], applicationActivities: nil)
        present(shareVC, animated: true, completion: nil)
    }
    
    
    func updateSecureButton(){
        if UserDefaults.standard.bool(forKey: "secure"){
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unsecure App", style: .plain, target: self, action: #selector(secureTap))
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Secure App", style: .plain, target: self, action: #selector(secureTap))
        }
    }
    
    @objc func secureTap(){
        if UserDefaults.standard.bool(forKey: "secure"){
            UserDefaults.standard.set(false, forKey: "secure")
        }else{
            UserDefaults.standard.set(true, forKey: "secure")
        }
        updateSecureButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoinData.shared.delegate = self
        tableView.reloadData()
        displayNetWorth()
    }
    
    func newPrices() {
        tableView.reloadData()
    }
    
    func createHeaderView() -> UIView{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerheight))
        headerView.backgroundColor = UIColor.white
        let networthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: networthheight))
        networthLabel.text = "My crypto currency net worth"
        networthLabel.textAlignment = .center
        amountLabel = UILabel(frame: CGRect(x: 0, y: networthheight, width: view.frame.size.width, height: headerheight - networthheight))
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.boldSystemFont(ofSize: 50)
        headerView.addSubview(amountLabel)
        headerView.addSubview(networthLabel)
        displayNetWorth()
        return headerView
    }
    
    func displayNetWorth(){
        amountLabel.text = CoinData.shared.netWorthAsString()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CoinData.shared.coins.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let coin = CoinData.shared.coins[indexPath.row]
        
        if coin.amount != 0{
            cell.textLabel?.text = "\(coin.shortCode) - \(coin.priceAsString()) - \(coin.amount)"
        }else{
           cell.textLabel?.text = "\(coin.shortCode) - \(coin.priceAsString())"
        }
        cell.imageView?.image = coin.image
        //print("the image is",coin.image)

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let priceVC = PriceVC()
        priceVC.coin = CoinData.shared.coins[indexPath.row]
        navigationController?.pushViewController(priceVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerheight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }

}
