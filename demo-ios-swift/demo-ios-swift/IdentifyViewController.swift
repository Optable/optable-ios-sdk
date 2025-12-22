//
//  IdentifyViewController.swift
//  demo-ios-swift
//
//  Copyright © 2020 Optable Technologies Inc. All rights reserved.
//  See LICENSE for details.
//

import OptableSDK
import UIKit

class IdentifyViewController: UIViewController {
    // MARK: Properties
    @IBOutlet var identifyInput: UITextField!
    @IBOutlet var identifyButton: UIButton!
    @IBOutlet var identifyIDFA: UISwitch!
    @IBOutlet var identifyOutput: UITextView!

    // MARK: Actions

    // dispatchIdentify() is the action invoked on a click on the "Identify" UIButton in our demo app. It initiates
    // a call to the OptableSDK.identify() API and prints debugging information to the UI and debug console.
    @IBAction func dispatchIdentify(_ sender: UIButton) {
        do {
            let email = identifyInput.text! as String
            let aaid = identifyIDFA.isOn as Bool

            identifyOutput.text = "Calling /identify API with:\n\n"
            if email != "" {
                identifyOutput.text += "Email: " + email + "\n"
            }
            identifyOutput.text += "IDFA: " + String(aaid) + "\n"

            let idfa = "06DE8C6A-A431-4235-A262-E3A9C2CCEB34"
            let gaid = "D04BB8C3-5A3E-4964-9757-D38365F59E6A"
            let phoneNumber = "+1234567890"
            let custom = "new-custom.ABC"
            let custom9 = "custom-9-id"

            try OPTABLE!.identify(
                OptableIdentifiers(emailAddress: email, phoneNumber: phoneNumber, appleIDFA: idfa, googleGAID: gaid, custom: ["c": custom, "c9": custom9]),
                { result in
                    switch result {
                    case let .success(response):
                        print("[OptableSDK] Success on /identify API call: response.statusCode = \(response.statusCode)")
                        DispatchQueue.main.async {
                            self.identifyOutput.text += "\n✅ Success. Response: \(response)"
                        }

                    case let .failure(error):
                        print("[OptableSDK] Error on /identify API call: \(error)")
                        DispatchQueue.main.async {
                            self.identifyOutput.text += "\n🚫 Error: \(error)"
                        }
                    }
                }
            )

        } catch {
            print("[OptableSDK] Exception: \(error)")
            identifyOutput.text += "EXCEPTION: \(error)"
        }
    }
}
