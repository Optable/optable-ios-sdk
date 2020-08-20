//
//  ViewController.swift
//  demo-ios-swift
//
//  Created by Bosko Milekic on 2020-08-06.
//  Copyright © 2020 Bosko Milekic. All rights reserved.
//

import UIKit
import CryptoKit
import AdSupport

class ViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var identifyInput: UITextField!
    @IBOutlet weak var identifyButton: UIButton!
    @IBOutlet weak var identifyIDFA: UISwitch!
    @IBOutlet weak var identifyOutput: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: Actions
    
    // dispatchIdentify() is the action invoked on a click on the "Identify" UIButton in our demo app. It initiates
    // a call to the OptableSDK.identify() API and prints debugging information to the UI and debug console.
    @IBAction func dispatchIdentify(_ sender: UIButton) {
        do {
            let email = identifyInput.text!
            var ids = [String: Any]()

            if email != "" {
                ids["eid"] = eid(email)
            }

            if identifyIDFA.isOn && ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                ids["idfa"] = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            }

            identifyOutput.text = "Calling /identify API with these IDs:\n\n"
            displayIdentifyIDs(ids)

            try OPTABLE!.identify(ids) { result in
                switch result {
                case .success(let response):
                    print("[OptableSDK] Success on /identify API call: response.statusCode = \(response.statusCode)")
                case .failure(let error):
                    print("[OptableSDK] Error on /identify API call: \(error)")
                }
            }

        } catch {
            print("[dispatchIdentity] Exception: \(error)")
            identifyOutput.text += "EXCEPTION: \(error)"
        }
    }

    // eid(email) is a helper that returns SHA256(downcase(email))
    private func eid(_ email: String) -> String {
        return SHA256.hash(data: Data(email.lowercased().utf8)).compactMap {
            String(format: "%02x", $0)
        }.joined()
    }

    // displayIdentifyIDs(ids) is a helper that prints the 'ids' dictionary which is the input to our OptableSDK.identify() call
    private func displayIdentifyIDs(_ ids: [String: Any]) {
        var output: String = ""
        for (type, typeids) in ids {
            if typeids is Array<String> {
                for id in (typeids as! Array<String>) {
                    output += "\(type) = \(id)\n\n"
                }
            } else if typeids is String {
                output += "\(type) = \(typeids as! String)\n\n"
            }
        }

        identifyOutput.text += output
    }
}
