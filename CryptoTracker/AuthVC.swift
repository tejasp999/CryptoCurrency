//
//  AuthVC.swift
//  CryptoTracker
//
//  Created by Teja PV on 10/25/18.
//  Copyright © 2018 Teja PV. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        presentAuth()
    }
    
    func presentAuth(){
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Your app is protected by Biometrics") { (success, error) in
            if success{
                DispatchQueue.main.async {
                    let cryptoVC = CryptoTableVC()
                    let navVC = UINavigationController(rootViewController: cryptoVC)
                    self.present(navVC, animated: true, completion: nil)
                }
            }else{
               self.presentAuth()
            }
        }
    }
    
    

}
